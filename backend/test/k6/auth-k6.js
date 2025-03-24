import http from 'k6/http';
import { sleep, check, group } from 'k6';
import { randomString } from 'https://jslib.k6.io/k6-utils/1.2.0/index.js';

// This function runs ONCE at the beginning of the test
export function setup() {
  // Generate unique credentials for our test user
  const uniqueId = randomString(8);
  const testUsername = `testuser${uniqueId}`;
  const testPassword = 'securePass@145';
  const testEmail = `${testUsername}@test.com`;
  
  const baseUrl = 'http://localhost:3000';
  
  // Register the test user
  const signupPayload = JSON.stringify({
    email: testEmail,
    password: testPassword,
    username: testUsername,
    location: "New York",
    phone: "+94456781861"
  });
  
  const signupParams = {
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }
  };
  
  const signupRes = http.post(
    `${baseUrl}/auth/signup`,
    signupPayload,
    signupParams
  );
  
  console.log(`Initial signup status: ${signupRes.status}`);
  
  try {
    const body = JSON.parse(signupRes.body);
    console.log(`Created test user: ${testUsername}`);
    
    // Return the test data for use in the default function
    return {
      baseUrl: baseUrl,
      username: testUsername,
      password: testPassword
    };
  } catch (e) {
    console.error(`Setup error: ${e.message}`);
    console.error(`Response: ${signupRes.status} - ${signupRes.body}`);
    
    // Return fallback data
    return {
      baseUrl: baseUrl,
      username: testUsername,
      password: testPassword
    };
  }
}

export const options = {
  stages: [
    { duration: '30s', target: 1 }, 
    { duration: '1m', target: 0 },  
  ],
  thresholds: {
    http_req_duration: ['p(95)<3500'],
    'http_req_duration{name:login}': ['p(95)<3500'],
  },
};

// Default function - uses the data from setup
export default function(data) {
  // Test login endpoint - Using our pre-registered account
  group('login', function() {
    const loginPayload = JSON.stringify({
      username: data.username,
      password: data.password
    });
    
    const loginParams = {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      tags: { name: 'login' }
    };
    
    const loginRes = http.post(
      `${data.baseUrl}/auth/login`,  
      loginPayload, 
      loginParams
    );
    
    // Check if login was successful
    check(loginRes, {
      'login status is 200': (r) => r.status === 200,
      'login returns token': (r) => {
        try {
          const body = JSON.parse(r.body);
          return body.token !== undefined;
        } catch (e) {
          console.error(`Login parse error: ${e.message}`);
          return false;
        }
      }
    });
    
    if (loginRes.status !== 200) {
      console.error(`Login failed: ${loginRes.status} - ${loginRes.body}`);
    }
  });
  
  // Add a small sleep to avoid hammering the server too hard
  sleep(1);
}