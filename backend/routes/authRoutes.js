/*
 File: authRoutes.js
 Purpose: Defines routes authentication and swagger documentation.
 Created Date: 2025-02-03 CCS-7 Ryan Fernando
 Author: Ryan Fernando
 swagger doc: Melissa Joanne 

 last modified: 2025-02-11 | Melissa | CCS-7 Routes for crud added
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
 *                 example: "user@example.com"
 *               password:
 *                 type: string
 *                 example: "securepassword"
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
 *                 message:
 *                   type: string
 *                   example: "User registered successfully."
 *       400:
 *         description: Bad request (missing or invalid parameters).
 *       409:
 *         description: Conflict (email already in use).
 */
router.post("/signup", authController.createUser);

/**
 * @swagger
 * /signin:
 *   post:
 *     summary: User login
 *     description: Authenticates a user and returns a token.
 *     tags:
 *       - Authentication
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 example: "user@example.com"
 *               password:
 *                 type: string
 *                 example: "securepassword"
 *     responses:
 *       200:
 *         description: Login successful, returns an access token.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 token:
 *                   type: string
 *                   example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
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

router.get("/user/:uid", authController.getUser);
router.get("/users", authController.getAllUsers);
router.put("/user/:uid", authController.updateUser);
router.delete("/user/:uid", authController.deleteUser);

module.exports = router;
