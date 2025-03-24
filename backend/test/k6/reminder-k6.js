import http from 'k6/http';
import { sleep, check, group } from 'k6';
import { SharedArray } from 'k6/data';
import { randomString } from 'https://jslib.k6.io/k6-utils/1.2.0/index.js';
import { Trend } from 'k6/metrics';

// Custom metric for tracking API response time
const reminderApiTrend = new Trend('reminder_api_response_time');

// Configure test parameters
export const options = {
  scenarios: {
    reminders_test: {
      executor: 'ramping-vus',
      startVUs: 1,
      stages: [
        { duration: '30s', target: 10 }, // Ramp up to 10 users
        { duration: '1m', target: 10 },  // Stay at 10 users for 1 minute
        { duration: '30s', target: 0 },  // Ramp down to 0 users
      ],
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<200'], // 95% of requests should be below 200ms
    'http_req_duration{endpoint:create_reminder}': ['p(95)<200'],
    'http_req_duration{endpoint:get_reminders}': ['p(95)<200'],
    'reminder_api_response_time': ['p(95)<200'],
  },
};

// Test data setup - runs once per test
export function setup() {
  const baseUrl = 'http://localhost:3000';
  
  // Create a test user and get a token
  const uniqueId = randomString(8);
  const testUser = {
    username: `testuser${uniqueId}`,
    password: 'Password@123',
    email: `testuser${uniqueId}@test.com`,
    location: "Test Location",
    phone: "+94712345678"
  };
  
  const signupRes = http.post(
    `${baseUrl}/auth/signup`,
    JSON.stringify(testUser),
    { headers: { 'Content-Type': 'application/json' } }
  );
  
  // Check if registration was successful
  if (signupRes.status !== 201) {
    console.error(`User creation failed: ${signupRes.status} - ${signupRes.body}`);
    
    // Try logging in instead
    const loginRes = http.post(
      `${baseUrl}/auth/login`,
      JSON.stringify({ email: testUser.email, password: testUser.password }),
      { headers: { 'Content-Type': 'application/json' } }
    );
    
    if (loginRes.status !== 200) {
      console.error(`Login failed: ${loginRes.status} - ${loginRes.body}`);
      return { baseUrl, token: null, userId: null };
    }
    
    // Parse token and user info
    const loginData = JSON.parse(loginRes.body);
    return { 
      baseUrl, 
      token: loginData.token, 
      userId: loginData.user.uid || loginData.user._id 
    };
  }
  
  // Parse token and user info from signup response
  const userData = JSON.parse(signupRes.body);
  
  return { 
    baseUrl, 
    token: userData.token, 
    userId: userData.user.uid || userData.user._id 
  };
}

export default function(data) {
  const { baseUrl, token, userId } = data;
  
  // Skip if setup failed
  if (!token || !userId) {
    console.log('Skipping test because setup failed');
    return;
  }
  
  const headers = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  };
  
  // Test creating a reminder
  group('Create Reminder', () => {
    const reminderData = {
      title: `Test Reminder ${randomString(4)}`,
      description: 'Performance test reminder',
      dateTime: new Date(Date.now() + 86400000).toISOString(), // Tomorrow
      timezone: 'Asia/Colombo',
      type: 'appointment'
    };
    
    const createParams = {
      headers,
      tags: { endpoint: 'create_reminder' }
    };
    
    const createStartTime = new Date();
    const createRes = http.post(
      `${baseUrl}/reminder/${userId}`,
      JSON.stringify(reminderData),
      createParams
    );
    const createDuration = new Date() - createStartTime;
    
    // Track custom metric
    reminderApiTrend.add(createDuration);
    
    check(createRes, {
      'Create reminder status is 201': (r) => r.status === 201,
      'Create reminder response time < 200ms': (r) => createDuration < 200
    });
    
    if (createRes.status !== 201) {
      console.error(`Create reminder failed: ${createRes.status} - ${createRes.body}`);
    }
  });
  
  // Test getting all reminders
  group('Get Reminders', () => {
    const getParams = {
      headers,
      tags: { endpoint: 'get_reminders' }
    };
    
    const getStartTime = new Date();
    const getRes = http.get(
      `${baseUrl}/reminder/${userId}`,
      getParams
    );
    const getDuration = new Date() - getStartTime;
    
    // Track custom metric
    reminderApiTrend.add(getDuration);
    
    check(getRes, {
      'Get reminders status is 200': (r) => r.status === 200,
      'Get reminders response time < 200ms': (r) => getDuration < 200
    });
    
    if (getRes.status !== 200) {
      console.error(`Get reminders failed: ${getRes.status} - ${getRes.body}`);
    }
  });
  
  // Wait a bit between iterations to avoid hammering the server
  sleep(1);
}
