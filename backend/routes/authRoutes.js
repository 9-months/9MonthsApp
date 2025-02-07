/*
 File: authRoutes.js
 Purpose: Defines routes authentication and swagger documentation.
 Created Date: 2025-02-03 CCS-7 Ryan Fernando
 Author: Ryan Fernando
 swagger doc: Melissa Joanne 

 last modified: 2025-02-05 | Melissa | CCS-7 API documentation update for authentication
*/

const express = require("express");
const authController = require("../controllers/authController");

const router = express.Router();

/**
 * @swagger
 * /signup:
 *   post:
 *     summary: User signup
 *     description: Registers a new user and returns a success message.
 *     tags:
 *       - Authentication
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - username
 *               - email
 *               - password
 *               - location
 *               - phone
 *             properties:
 *               username:
 *                 type: string
 *                 example: "JohnDoe"
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "john.doe@example.com"
 *               password:
 *                 type: string
 *                 format: password
 *                 minLength: 6
 *                 example: "securepassword123"
 *               location:
 *                 type: string
 *                 example: "New York, USA"
 *               phone:
 *                 type: string
 *                 example: "+1234567890"
 *     responses:
 *       201:
 *         description: User registered successfully.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "User created successfully"
 *       400:
 *         description: Bad request (missing or invalid parameters).
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                   example: false
 *                 message:
 *                   type: string
 *                   example: "Invalid email format"
 *       409:
 *         description: Conflict (email or username already in use).
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                   example: false
 *                 message:
 *                   type: string
 *                   example: "Email is already registered"
 */
router.post("/signup", authController.createUser);

/**
 * @swagger
 * /login:
 *   post:
 *     summary: User login
 *     description: Authenticates a user using either email or username and returns a token.
 *     tags:
 *       - Authentication
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             oneOf:
 *               - type: object
 *                 required:
 *                   - email
 *                   - password
 *                 properties:
 *                   email:
 *                     type: string
 *                     format: email
 *                     example: "john.doe@example.com"
 *                   password:
 *                     type: string
 *                     format: password
 *                     example: "securepassword123"
 *               - type: object
 *                 required:
 *                   - username
 *                   - password
 *                 properties:
 *                   username:
 *                     type: string
 *                     example: "JohnDoe"
 *                   password:
 *                     type: string
 *                     format: password
 *                     example: "securepassword123"
 *     responses:
 *       200:
 *         description: Login successful
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "Logged in successfully"
 *                 token:
 *                   type: string
 *                   example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 *                 user:
 *                   type: object
 *                   properties:
 *                     uid:
 *                       type: string
 *                       example: "user123"
 *                     email:
 *                       type: string
 *                       example: "john.doe@example.com"
 *                     username:
 *                       type: string
 *                       example: "JohnDoe"
 *       400:
 *         description: Bad request (missing or invalid parameters)
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                   example: false
 *                 message:
 *                   type: string
 *                   example: "Email/username and password are required"
 *       401:
 *         description: Unauthorized (invalid credentials)
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: boolean
 *                   example: false
 *                 message:
 *                   type: string
 *                   example: "Invalid credentials"
 */
router.post("/login", authController.logIn);
/**
 * @swagger
 * /google-signin:
 *   post:
 *     summary: Google Sign-in
 *     description: Authenticates a user using Google OAuth and returns a token.
 *     tags:
 *       - Authentication
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - token
 *             properties:
 *               token:
 *                 type: string
 *                 example: "google-oauth-token"
 *     responses:
 *       200:
 *         description: Google sign-in successful, returns an access token.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 token:
 *                   type: string
 *                   example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 *       400:
 *         description: Bad request (invalid token).
 *       401:
 *         description: Unauthorized (invalid credentials).
 */
router.post("/google-signin", authController.googleSignIn);

module.exports = router;
