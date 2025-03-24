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
const { verifyToken } = require('../middleware/authMiddleware');
const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Moods
 *   description: API endpoints for mood tracking
 */

/**
 * @swagger
 * components:
 *   schemas:
 *     MoodEntry:
 *       type: object
 *       properties:
 *         _id:
 *           type: string
 *           description: The auto-generated ID of the mood entry
 *         userId:
 *           type: string
 *           description: The user ID associated with the mood entry
 *         mood:
 *           type: string
 *           description: The mood of the user
 *           enum: [happy, sad, anxious, calm, stressed, excited]
 *         note:
 *           type: string
 *           description: Additional note for the mood entry
 *         date:
 *           type: string
 *           format: date-time
 *           description: The date when the mood was recorded
 *       example:
 *         _id: 60d21b4667d0d8992e610c85
 *         userId: user123
 *         mood: happy
 *         note: Had a great day today!
 *         date: 2025-02-11T08:30:00.000Z
 */

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
 *     responses:
 *       201:
 *         description: Mood entry created successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MoodEntry'
 *       400:
 *         description: Invalid request data
 *       401:
 *         description: Unauthorized - invalid or missing token
 *       500:
 *         description: Server error
 */
router.post('/create/:userId', verifyToken, moodController.createMoodEntry);

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
 *     responses:
 *       200:
 *         description: A list of mood entries
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/MoodEntry'
 *       401:
 *         description: Unauthorized - invalid or missing token
 *       500:
 *         description: Server error
 */
router.get('/getAll/:userId', verifyToken, moodController.getMoodEntries);

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
 *     responses:
 *       200:
 *         description: A mood entry
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MoodEntry'
 *       401:
 *         description: Unauthorized - invalid or missing token
 *       404:
 *         description: Mood entry not found
 *       500:
 *         description: Server error
 */
router.get('/get/:userId/:moodId', verifyToken, moodController.getMoodEntry);

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
 *     responses:
 *       200:
 *         description: Mood entry updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MoodEntry'
 *       400:
 *         description: Invalid request data
 *       401:
 *         description: Unauthorized - invalid or missing token
 *       404:
 *         description: Mood entry not found
 *       500:
 *         description: Server error
 */
router.put('/update/:userId/:moodId', verifyToken, moodController.updateMoodEntry);

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
 *     responses:
 *       200:
 *         description: Mood entry deleted successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Mood entry successfully deleted
 *       401:
 *         description: Unauthorized - invalid or missing token
 *       404:
 *         description: Mood entry not found
 *       500:
 *         description: Server error
 */
router.delete('/delete/:userId/:moodId', verifyToken, moodController.deleteMoodEntry);

module.exports = router;