import http from 'k6/http';
import { sleep, check, group } from 'k6';
import { randomString } from 'https://jslib.k6.io/k6-utils/1.2.0/index.js';
import { Trend } from 'k6/metrics';

// Custom metric for tracking API response time
const moodApiTrend = new Trend('mood_api_response_time');

// Define available moods for random selection
const availableMoods = ['happy', 'sad', 'anxious', 'calm', 'stressed', 'excited'];

// Configure test parameters
export const options = {
  scenarios: {
    moods_test: {
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
    'http_req_duration{endpoint:create_mood}': ['p(95)<200'],
    'http_req_duration{endpoint:get_moods}': ['p(95)<200'],
    'http_req_duration{endpoint:get_mood}': ['p(95)<200'],
    'http_req_duration{endpoint:update_mood}': ['p(95)<200'],
    'mood_api_response_time': ['p(95)<200'],
  },
};

// Helper function to get a random mood
function getRandomMood() {
  return availableMoods[Math.floor(Math.random() * availableMoods.length)];
}

// Test data setup - runs once per test
export function setup() {
  const baseUrl = 'http://localhost:3000';
  
  // Create a test user and get a token
  const uniqueId = randomString(8);
  const testUser = {
    username: `moodtestuser${uniqueId}`,
    password: 'Password@123',
    email: `moodtestuser${uniqueId}@test.com`,
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
      userId: loginData.user.uid || loginData.user._id,
      createdMoodIds: []
    };
  }
  
  // Parse token and user info from signup response
  const userData = JSON.parse(signupRes.body);
  
  return { 
    baseUrl, 
    token: userData.token, 
    userId: userData.user.uid || userData.user._id,
    createdMoodIds: []
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
  
  // Test creating a mood entry
  group('Create Mood Entry', () => {
    const moodData = {
      mood: getRandomMood(),
      note: `Performance test mood entry ${randomString(4)}`
    };
    
    const createParams = {
      headers,
      tags: { endpoint: 'create_mood' }
    };
    
    const createStartTime = new Date();
    const createRes = http.post(
      `${baseUrl}/moods/create/${userId}`,
      JSON.stringify(moodData),
      createParams
    );
    const createDuration = new Date() - createStartTime;
    
    // Track custom metric
    moodApiTrend.add(createDuration);
    
    check(createRes, {
      'Create mood status is 201': (r) => r.status === 201,
      'Create mood response time < 200ms': (r) => createDuration < 200,
      'Create mood returns valid data': (r) => {
        if (r.status === 201) {
          try {
            const body = JSON.parse(r.body);
            // Store the mood ID for later use
            if (body._id) {
              data.createdMoodIds.push(body._id);
            }
            return true;
          } catch (e) {
            console.error(`Failed to parse response: ${e.message}`);
            return false;
          }
        }
        return false;
      }
    });
    
    if (createRes.status !== 201) {
      console.error(`Create mood failed: ${createRes.status} - ${createRes.body}`);
    }
  });
  
  // Test getting all mood entries
  group('Get All Mood Entries', () => {
    const getParams = {
      headers,
      tags: { endpoint: 'get_moods' }
    };
    
    const getStartTime = new Date();
    const getRes = http.get(
      `${baseUrl}/moods/getAll/${userId}`,
      getParams
    );
    const getDuration = new Date() - getStartTime;
    
    // Track custom metric
    moodApiTrend.add(getDuration);
    
    check(getRes, {
      'Get moods status is 200': (r) => r.status === 200,
      'Get moods response time < 200ms': (r) => getDuration < 200
    });
    
    if (getRes.status !== 200) {
      console.error(`Get moods failed: ${getRes.status} - ${getRes.body}`);
    } else {
      try {
        // If we don't have a mood ID stored yet, get one from this response
        const moods = JSON.parse(getRes.body);
        if (Array.isArray(moods) && moods.length > 0 && data.createdMoodIds.length === 0) {
          data.createdMoodIds.push(moods[0]._id);
        }
      } catch (e) {
        console.error(`Failed to parse moods: ${e.message}`);
      }
    }
  });
  
  // If we've created or found a mood, test single mood operations
  if (data.createdMoodIds.length > 0) {
    const moodId = data.createdMoodIds[0];
    
    // Test getting a specific mood entry
    group('Get Specific Mood Entry', () => {
      const getParams = {
        headers,
        tags: { endpoint: 'get_mood' }
      };
      
      const getStartTime = new Date();
      const getRes = http.get(
        `${baseUrl}/moods/get/${userId}/${moodId}`,
        getParams
      );
      const getDuration = new Date() - getStartTime;
      
      // Track custom metric
      moodApiTrend.add(getDuration);
      
      check(getRes, {
        'Get specific mood status is 200': (r) => r.status === 200,
        'Get specific mood response time < 200ms': (r) => getDuration < 200
      });
      
      if (getRes.status !== 200) {
        console.error(`Get specific mood failed: ${getRes.status} - ${getRes.body}`);
      }
    });
    
    // Test updating a mood entry
    group('Update Mood Entry', () => {
      const updateData = {
        mood: getRandomMood(),
        note: `Updated mood entry ${randomString(4)}`
      };
      
      const updateParams = {
        headers,
        tags: { endpoint: 'update_mood' }
      };
      
      const updateStartTime = new Date();
      const updateRes = http.put(
        `${baseUrl}/moods/update/${userId}/${moodId}`,
        JSON.stringify(updateData),
        updateParams
      );
      const updateDuration = new Date() - updateStartTime;
      
      // Track custom metric
      moodApiTrend.add(updateDuration);
      
      check(updateRes, {
        'Update mood status is 200': (r) => r.status === 200,
        'Update mood response time < 200ms': (r) => updateDuration < 200
      });
      
      if (updateRes.status !== 200) {
        console.error(`Update mood failed: ${updateRes.status} - ${updateRes.body}`);
      }
    });
    
    // Only delete in some iterations to keep some data for retrieval tests
    if (Math.random() > 0.7) {
      // Test deleting a mood entry
      group('Delete Mood Entry', () => {
        const deleteParams = {
          headers,
          tags: { endpoint: 'delete_mood' }
        };
        
        const deleteStartTime = new Date();
        const deleteRes = http.del(
          `${baseUrl}/moods/delete/${userId}/${moodId}`,
          null,
          deleteParams
        );
        const deleteDuration = new Date() - deleteStartTime;
        
        // Track custom metric
        moodApiTrend.add(deleteDuration);
        
        check(deleteRes, {
          'Delete mood status is 200': (r) => r.status === 200,
          'Delete mood response time < 200ms': (r) => deleteDuration < 200
        });
        
        if (deleteRes.status !== 200) {
          console.error(`Delete mood failed: ${deleteRes.status} - ${deleteRes.body}`);
        } else {
          // Remove the ID from our list
          data.createdMoodIds = data.createdMoodIds.filter(id => id !== moodId);
        }
      });
    }
  }
  
  // Wait a bit between iterations to avoid hammering the server
  sleep(1);
}
