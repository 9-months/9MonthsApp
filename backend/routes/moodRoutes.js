const express = require('express');
const moodController = require('../controllers/moodController');
const router = express.Router();

/**
 * @swagger
 * /moods:
 *   post:
 *     summary: Create a new mood entry
 *     tags: [Moods]
 *     security:
 *       - bearerAuth: []
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
router.post('/', moodController.createMoodEntry);

/**
 * @swagger
 * /moods:
 *   get:
 *     summary: Get all mood entries for the user
 *     tags: [Moods]
 *     security:
 *       - bearerAuth: []
 */
router.get('/', moodController.getMoodEntries);

module.exports = router;