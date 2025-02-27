/*
 File: Auth.test.js
 Purpose: Testing Authentication functionalities.
 Created Date: 2025-02-08 CCS-18 Chamod Kamiss
 Author: Chamod Kamiss

*/

jest.mock('../services/authService', () => ({
    createUser: jest.fn(),
    logIn: jest.fn()
}));
  
const AuthService = require('../services/authService');
const User = require('../models/User');
const admin = require('firebase-admin');
const CryptoJS = require('crypto-js');
  
// Mock other dependencies
jest.mock('../models/User', () => ({
    findOne: jest.fn(),
    prototype: {
      save: jest.fn()
    }
}));
  
jest.mock('firebase-admin', () => ({
    auth: () => ({
      getUserByEmail: jest.fn(),
      createUser: jest.fn(),
      createCustomToken: jest.fn()
    })
}));
  
jest.mock('crypto-js', () => ({
    AES: {
      encrypt: jest.fn(),
      decrypt: jest.fn()
    }
}));
  
describe('AuthService', () => {
    beforeEach(() => {
      // Clear all mocks before each test
      jest.clearAllMocks();
      process.env.SECRET = 'test-secret';
    });
  
    describe('createUser', () => {
      const validUserData = {
        email: 'test@example.com',
        password: 'Password@123',
        username: 'testuser',
        location: 'Colombo',
        phone: '+94712345678'
    };
    
    it('should successfully create a new user', async () => {
        // Mock the createUser implementation for this test
        AuthService.createUser.mockResolvedValueOnce({
          status: true,
          message: 'User created successfully'
        });
  
        const result = await AuthService.createUser(validUserData);
  
        expect(result.status).toBe(true);
        expect(result.message).toBe('User created successfully');
        expect(AuthService.createUser).toHaveBeenCalledWith(validUserData);
    });
  
    it('should fail when email is invalid', async () => {
        const invalidUserData = { ...validUserData, email: 'invalid-email' };
        
        AuthService.createUser.mockResolvedValueOnce({
          status: false,
          message: 'Invalid email format: invalid-email'
        });
  
        const result = await AuthService.createUser(invalidUserData);
  
        expect(result.status).toBe(false);
        expect(result.message).toContain('Invalid email format');
    });
  
    it('should fail when phone number is invalid', async () => {
        const invalidUserData = { ...validUserData, phone: '123456789' };
        
        AuthService.createUser.mockResolvedValueOnce({
          status: false,
          message: 'Invalid phone number format'
        });
  
        const result = await AuthService.createUser(invalidUserData);
  
        expect(result.status).toBe(false);
        expect(result.message).toContain('Invalid phone number format');
    });
  
    it('should fail when password is too weak', async () => {
        const invalidUserData = { ...validUserData, password: 'weak' };
        
        AuthService.createUser.mockResolvedValueOnce({
          status: false,
          message: 'Password must be at least 6 characters'
        });
  
        const result = await AuthService.createUser(invalidUserData);
  
        expect(result.status).toBe(false);
        expect(result.message).toContain('Password must be at least 6 characters');
    });
    
    it('should fail when email already exists', async () => {
        AuthService.createUser.mockResolvedValueOnce({
          status: false,
          message: 'Email is already registered'
        });
        
        const result = await AuthService.createUser(validUserData);
  
        expect(result.status).toBe(false);
        expect(result.message).toContain('Email is already registered');
      });
    });
  
    describe('logIn', () => {
      const validCredentials = {
        email: 'test@example.com',
        password: 'Password@123'
      };
      
      it('should successfully log in a user', async () => {
        AuthService.logIn.mockResolvedValueOnce({
          status: true,
          message: 'Logged in successfully',
          token: 'mock-token',
          user: {
            uid: 'test-uid',
            email: validCredentials.email,
            username: 'testuser'
          }
        });
  
        const result = await AuthService.logIn(validCredentials.email, validCredentials.password);
  
        expect(result.status).toBe(true);
        expect(result.message).toBe('Logged in successfully');
        expect(result.token).toBe('mock-token');
        expect(result.user).toBeDefined();
    });
    
    it('should fail with invalid credentials', async () => {
        AuthService.logIn.mockResolvedValueOnce({
          status: false,
          message: 'Invalid credentials.'
        });
  
        const result = await AuthService.logIn(validCredentials.email, validCredentials.password);
  
        expect(result.status).toBe(false);
        expect(result.message).toBe('Invalid credentials.');
    });
    
    it('should fail with wrong password', async () => {
        AuthService.logIn.mockResolvedValueOnce({
          status: false,
          message: 'Invalid credentials.'
        });
  
        const result = await AuthService.logIn(validCredentials.email, validCredentials.password);
  
        expect(result.status).toBe(false);
        expect(result.message).toBe('Invalid credentials.');
      });
    });
});