/*
 File: moodRouter.js
 Purpose: Defines routes for mood tracking and swagger documentation.
 Created Date: 11-02-2025 CCS-48 Dinith Perera
 Author: Dinith Perera
 swagger doc: Dinith Perera

 last modified: 11-02-2025 | Dinith | CCS-48 API documentation update for mood tracking
*/

const express = require('express');
const moodController = require('../controllers/moodController');
const router = express.Router();

/**
 * @swagger
 * /moods/create/{userId}:
 *   post:
 *     summary: Create a new mood entry
 *     tags: [Moods]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *         description: The user ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - mood
 *             properties:
 *               mood:
 *                 type: string
 *                 enum: [happy, sad, anxious, calm, stressed, excited]
 *               note:
 *                 type: string
 */
router.post('/create/:userId', moodController.createMoodEntry);

/**
 * @swagger
 * /moods/getAll/{userId}:
 *   get:
 *     summary: Get all mood entries for the user
 *     tags: [Moods]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *         description: The user ID
 */
router.get('/getAll/:userId', moodController.getMoodEntries);

/**
 * @swagger
 * /moods/get/{userId}/{moodId}:
 *   get:
 *     summary: Get a specific mood entry for the user
 *     tags: [Moods]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *         description: The user ID
 *       - in: path
 *         name: moodId
 *         required: true
 *         schema:
 *           type: string
 *         description: The mood ID
 */
router.get('/get/:userId/:moodId', moodController.getMoodEntry);

/**
 * @swagger
 * /moods/update/{userId}/{moodId}:
 *   put:
 *     summary: Update a specific mood entry for the user
 *     tags: [Moods]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *         description: The user ID
 *       - in: path
 *         name: moodId
 *         required: true
 *         schema:
 *           type: string
 *         description: The mood ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - mood
 *             properties:
 *               mood:
 *                 type: string
 *                 enum: [happy, sad, anxious, calm, stressed, excited]
 *               note:
 *                 type: string
 */
router.put('/update/:userId/:moodId', moodController.updateMoodEntry);

/**
 * @swagger
 * /moods/delete/{userId}/{moodId}:
 *   delete:
 *     summary: Delete a specific mood entry for the user
 *     tags: [Moods]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *         description: The user ID
 *       - in: path
 *         name: moodId
 *         required: true
 *         schema:
 *           type: string
 *         description: The mood ID
 */
router.delete('/delete/:userId/:moodId', moodController.deleteMoodEntry);

module.exports = router;