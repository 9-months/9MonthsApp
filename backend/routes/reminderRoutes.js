/*
 File: reminderRoutes.js
 Purpose: Defines routes for reminders and swagger documentation.
 Created Date: 2025-02-14 CCS-59 
 Author: Ryan Fernando
 swagger doc: Updated by Ryan Fernando

 last modified: 2025-03-25 | Ryan | Added Swagger documentation
*/

const express = require('express');
const router = express.Router();
const reminderController = require('../controllers/reminderController');
const { verifyToken } = require('../middleware/authMiddleware');

/**
 * @swagger
 * tags:
 *   name: Reminders
 *   description: API endpoints for managing pregnancy-related reminders
 */

/**
 * @swagger
 * components:
 *   schemas:
 *     Reminder:
 *       type: object
 *       properties:
 *         _id:
 *           type: string
 *           description: The auto-generated ID of the reminder
 *         userId:
 *           type: string
 *           description: The user ID associated with the reminder
 *         title:
 *           type: string
 *           description: The title of the reminder
 *         description:
 *           type: string
 *           description: The description of the reminder
 *         date:
 *           type: string
 *           format: date-time
 *           description: The date and time of the reminder
 *         category:
 *           type: string
 *           enum: [appointment, medication, checkup, other]
 *           description: The category of the reminder
 *         isCompleted:
 *           type: boolean
 *           description: Whether the reminder has been completed or not
 *         createdAt:
 *           type: string
 *           format: date-time
 *           description: The date when the reminder was created
 *       example:
 *         _id: 60d21b4667d0d8992e610c85
 *         userId: user123
 *         title: Doctor Appointment
 *         description: Monthly checkup with Dr. Sarah
 *         date: 2025-03-15T09:30:00.000Z
 *         category: appointment
 *         isCompleted: false
 *         createdAt: 2025-03-01T08:30:00.000Z
 */

/**
 * @swagger
 * /reminder/{userId}:
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
 *                 description: Title of the reminder
 *               description:
 *                 type: string
 *                 description: Detailed description of the reminder
 *               date:
 *                 type: string
 *                 format: date-time
 *                 description: When the reminder is due
 *               category:
 *                 type: string
 *                 enum: [appointment, medication, checkup, other]
 *                 default: other
 *     responses:
 *       201:
 *         description: Reminder created successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Reminder'
 *       400:
 *         description: Invalid request data
 *       401:
 *         description: Unauthorized - invalid or missing token
 *       500:
 *         description: Server error
 */
router.post('/:userId', verifyToken, reminderController.createReminder);

/**
 * @swagger
 * /reminder/{userId}:
 *   get:
 *     summary: Get all reminders for a user
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
 *     responses:
 *       200:
 *         description: A list of reminders
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Reminder'
 *       401:
 *         description: Unauthorized - invalid or missing token
 *       500:
 *         description: Server error
 */
router.get('/:userId', verifyToken, reminderController.getRemindersByUser);

/**
 * @swagger
 * /reminder/{userId}/{reminderId}:
 *   get:
 *     summary: Get a specific reminder
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
 *     responses:
 *       200:
 *         description: The reminder details
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Reminder'
 *       401:
 *         description: Unauthorized - invalid or missing token
 *       404:
 *         description: Reminder not found
 *       500:
 *         description: Server error
 */
router.get('/:userId/:reminderId', verifyToken, reminderController.getReminder);

/**
 * @swagger
 * /reminder/{userId}/{reminderId}:
 *   put:
 *     summary: Update a specific reminder
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
 *             properties:
 *               title:
 *                 type: string
 *                 description: Title of the reminder
 *               description:
 *                 type: string
 *                 description: Detailed description of the reminder
 *               date:
 *                 type: string
 *                 format: date-time
 *                 description: When the reminder is due
 *               category:
 *                 type: string
 *                 enum: [appointment, medication, checkup, other]
 *               isCompleted:
 *                 type: boolean
 *                 description: Whether the reminder has been completed
 *     responses:
 *       200:
 *         description: Reminder updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Reminder'
 *       400:
 *         description: Invalid request data
 *       401:
 *         description: Unauthorized - invalid or missing token
 *       404:
 *         description: Reminder not found
 *       500:
 *         description: Server error
 */
router.put('/:userId/:reminderId', verifyToken, reminderController.updateReminder);

/**
 * @swagger
 * /reminder/{userId}/{reminderId}:
 *   delete:
 *     summary: Delete a specific reminder
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
 *     responses:
 *       200:
 *         description: Reminder deleted successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Reminder successfully deleted
 *       401:
 *         description: Unauthorized - invalid or missing token
 *       404:
 *         description: Reminder not found
 *       500:
 *         description: Server error
 */
router.delete('/:userId/:reminderId', verifyToken, reminderController.deleteReminder);

module.exports = router;