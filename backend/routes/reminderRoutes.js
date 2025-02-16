const express = require('express');
const reminderController = require('../controllers/reminderController');
const router = express.Router();

/**
 * @swagger
 * /reminders/create/{userId}:
 *   post:
 *     summary: Create a new reminder
 *     tags: [Reminders]
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
 *               - title
 *               - date
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               date:
 *                 type: string
 *                 format: date-time
 */
router.post('/create/:userId', reminderController.createReminder);

/**
 * @swagger
 * /reminders/getAll/{userId}:
 *   get:
 *     summary: Get all reminders for the user
 *     tags: [Reminders]
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
router.get('/getAll/:userId', reminderController.getRemindersByUser);

/**
 * @swagger
 * /reminders/get/{userId}/{reminderId}:
 *   get:
 *     summary: Get a specific reminder for the user
 *     tags: [Reminders]
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
 *         name: reminderId
 *         required: true
 *         schema:
 *           type: string
 *         description: The reminder ID
 */
router.get('/get/:userId/:reminderId', reminderController.getReminder);

/**
 * @swagger
 * /reminders/update/{userId}/{reminderId}:
 *   put:
 *     summary: Update a specific reminder for the user
 *     tags: [Reminders]
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
 *         name: reminderId
 *         required: true
 *         schema:
 *           type: string
 *         description: The reminder ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - title
 *               - date
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               date:
 *                 type: string
 *                 format: date-time
 */
router.put('/update/:userId/:reminderId', reminderController.updateReminder);

/**
 * @swagger
 * /reminders/delete/{userId}/{reminderId}:
 *   delete:
 *     summary: Delete a specific reminder for the user
 *     tags: [Reminders]
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
 *         name: reminderId
 *         required: true
 *         schema:
 *           type: string
 *         description: The reminder ID
 */
router.delete('/delete/:userId/:reminderId', reminderController.deleteReminder);

module.exports = router;
