/*
 File: emergencyRouter.js
 Purpose: Defines routes for emergency btn and swagger documentation.
 Created Date: 2025-02-03 CCS-9 Dinith Perera
 Author: Dinith Perera
 swagger doc: Melissa Joanne 

 last modified: 2025-02-03 | Melissa | CCS-9 API documentation update for emergency call feature
*/

// emergencyRouter.js (your existing router file)
const express = require('express');
const emergencyController = require('./emergencyController');

const router = express.Router();

/**
 * @swagger
 * /emergency:
 *   post:
 *     summary: Handle emergency requests from users.
 *     description: This endpoint processes emergency requests for pregnant users.
 *     tags:
 *       - Emergency
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               userId:
 *                 type: string
 *                 description: The ID of the user sending the emergency request.
 *               location:
 *                 type: string
 *                 description: The location of the emergency.
 *               message:
 *                 type: string
 *                 description: A message describing the emergency.
 *             required:
 *               - userId
 *               - location
 *               - message
 *     responses:
 *       200:
 *         description: Emergency request processed successfully.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   description: Status of the request.
 *                   example: "success"
 *       400:
 *         description: Invalid request body or missing parameters.
 *       500:
 *         description: Internal server error.
 */
router.post('/emergency', (req, res) => emergencyController.handleEmergencyRequest(req, res));

module.exports = router;
