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
const { verifyToken } = require('../middleware/authMiddleware');

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
 * /complete-profile:
 *  patch:
 *   summary: Complete user profile
 *   description: Completes the user's profile by adding their Account Type, Birthday, and Phone number.
 *   tags: [Authentication]
 *   requestBody:
 *    required: true
 *    content:
 *      application/json:
 *       schema:
 *          type: object
 *          properties:
 *              accountType:
 *                  type: string
 *                  example: "mother"
 *              birthday:
 *                  type: string
 *                  format: date
 *                  example: "2003-01-01"
 *              location:
 *                  type: string
 *                  example: "Ragama"
 *              phone:
 *                  type: string
 *                  example: "+9476543210"
 *   responses:
 *      200:
 *          description: Profile completed successfully.
 *      400:
 *          description: Invalid request parameters.
 *      404:
 *          description: User not found.
 */
router.patch("/complete-profile", verifyToken, authController.completeProfile);
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
router.get("/user/:uid", verifyToken, authController.getUser);

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
router.get("/users", verifyToken, authController.getAllUsers);

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
router.put("/user/:uid", verifyToken, authController.updateUser);

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
router.delete("/user/:uid", verifyToken, authController.deleteUser);

/**
 * @swagger
 * /current-user:
 *   get:
 *     summary: Get current authenticated user
 *     description: Returns details of the currently authenticated user
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User details retrieved successfully
 *       401:
 *         description: Unauthorized - invalid or missing token
 *       500:
 *         description: Server error
 */
router.get("/current-user", verifyToken, authController.getCurrentUser);

module.exports = router;
