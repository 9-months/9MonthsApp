/*
 File: authRoutes.js
 Purpose: Defines routes authentication and swagger documentation.
 Created Date: 2025-02-03 CCS-7 Ryan Fernando
 Author: Ryan Fernando
 swagger doc: Melissa Joanne 

 last modified: 2025-02-08 | Melissa | CCS-7 API documentation update for authentication
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
 *                 example: "+94712345678"
 *     responses:
 *       201:
 *         description: User created successfully.
 *         content:
 *           application/json:
 *             example:
 *               message: "User created successfully."
 *       400:
 *         description: Bad request (missing or invalid parameters).
 *       409:
 *         description: Conflict (email or username already in use).
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
 *             type: object
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "john.doe@example.com"
 *               username:
 *                 type: string
 *                 example: "JohnDoe"
 *               password:
 *                 type: string
 *                 format: password
 *                 example: "securepassword123"
 *             oneOf:
 *               - required: [email, password]
 *               - required: [username, password]
 *     responses:
 *       200:
 *         description: Login successful.
 *         content:
 *           application/json:
 *             example:
 *               message: "Logged in successfully."
 *               token: "your_jwt_token_here"
 *               user:
 *                 uid: "user_id"
 *                 email: "user@example.com"
 *                 username: "username"
 *       400:
 *         description: Bad request (missing or invalid parameters).
 *       401:
 *         description: Unauthorized (invalid credentials).
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
 *               - idToken
 *             properties:
 *               idToken:
 *                 type: string
 *                 example: "google-oauth-token"
 *     responses:
 *       200:
 *         description: Google sign-in successful.
 *         content:
 *           application/json:
 *             example:
 *               message: "Google sign-in successful."
 *       400:
 *         description: Bad request (invalid token).
 *       401:
 *         description: Unauthorized (invalid credentials).
 */
router.post("/google-signin", authController.googleSignIn);


module.exports = router;
