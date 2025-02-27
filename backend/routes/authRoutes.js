/*
 File: authRoutes.js
 Purpose: Defines routes authentication and swagger documentation.
 Created Date: 2025-02-03 CCS-7 Ryan Fernando
 Author: Ryan Fernando
 swagger doc: Melissa Joanne 

 last modified: 2025-02-11 | Melissa | CCS-7 Routes for crud added
*/

/**
 * @swagger
 * tags:
 *   name: Authentication
 *   description: API endpoints for user authentication and management
 */

const express = require("express");
const authController = require("../controllers/authController");

const router = express.Router();

/**
 * @swagger
 * /signup:
 *   post:
 *     summary: Register a new user
 *     description: Creates a new user account.
 *     tags: [Authentication]
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
 *         description: User registered successfully.
 *       400:
 *         description: Bad request (missing or invalid parameters).
 *       409:
 *         description: Email already in use.
 */
router.post("/signup", authController.createUser);

/**
 * @swagger
 * /login:
 *   post:
 *     summary: User login
 *     description: Authenticates a user and returns a JWT token.
 *     tags: [Authentication]
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
 *         description: Login successful, returns a token.
 *       400:
 *         description: Missing or invalid credentials.
 *       401:
 *         description: Unauthorized.
 */
router.post("/login", authController.logIn);

/**
 * @swagger
 * /google-signin:
 *   post:
 *     summary: Google authentication
 *     description: Allows users to log in using their Google account.
 *     tags: [Authentication]
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
 *         description: Google sign-in successful, returns a token.
 *       400:
 *         description: Invalid token.
 *       401:
 *         description: Unauthorized.
 */
router.post("/google-signin", authController.googleSignIn);

/**
 * @swagger
 * /user/{uid}:
 *   get:
 *     summary: Retrieve a single user
 *     description: Fetches a user by their unique ID.
 *     tags: [Authentication]
 *     parameters:
 *       - in: path
 *         name: uid
 *         required: true
 *         schema:
 *           type: string
 *         description: User's unique ID.
 *     responses:
 *       200:
 *         description: User details retrieved successfully.
 *       404:
 *         description: User not found.
 */
router.get("/user/:uid", authController.getUser);

/**
 * @swagger
 * /users:
 *   get:
 *     summary: Get all users
 *     description: Retrieves a list of all registered users.
 *     tags: [Authentication]
 *     responses:
 *       200:
 *         description: Successfully retrieved user list.
 *       500:
 *         description: Server error.
 */
router.get("/users", authController.getAllUsers);

/**
 * @swagger
 * /user/{uid}:
 *   put:
 *     summary: Update user details (Only email, phone, and location)
 *     description: Updates the user's email, phone, and location.
 *     tags: [Authentication]
 *     parameters:
 *       - in: path
 *         name: uid
 *         required: true
 *         schema:
 *           type: string
 *         description: User's unique ID.
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               email:
 *                 type: string
 *                 example: "newemail@example.com"
 *               phone:
 *                 type: string
 *                 example: "+9876543210"
 *               location:
 *                 type: string
 *                 example: "Los Angeles, USA"
 *     responses:
 *       200:
 *         description: User updated successfully.
 *       400:
 *         description: Invalid request parameters.
 *       404:
 *         description: User not found.
 */
router.put("/user/:uid", authController.updateUser);

/**
 * @swagger
 * /user/{uid}:
 *   delete:
 *     summary: Delete a user
 *     description: Deletes a user by their unique ID.
 *     tags: [Authentication]
 *     parameters:
 *       - in: path
 *         name: uid
 *         required: true
 *         schema:
 *           type: string
 *         description: User's unique ID.
 *     responses:
 *       200:
 *         description: User deleted successfully.
 *       404:
 *         description: User not found.
 */
router.delete("/user/:uid", authController.deleteUser);

module.exports = router;
