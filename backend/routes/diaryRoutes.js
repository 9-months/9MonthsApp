/*
 File: diaryRoutes.js
 Purpose: Defines routes for diary and swagger documentation.
 Created Date: 23-02-2025 CCS-50 Melissa Joanne
 Author: Melissa Joanne
 

 last modified: 23-02-2025 | Melissa | CCS-50 Swagger documentation for diary routes
*/
const express = require("express");
const router = express.Router();
const diaryController = require("../controllers/diaryController");

/**
 * @swagger
 * definitions:
 *   DiaryEntry:
 *     type: object
 *     properties:
 *       _id:
 *         type: string
 *         description: Unique identifier for the diary entry.
 *       description:
 *         type: string
 *         description: Detailed description of the diary entry.
 *       date:
 *         type: string
 *         format: date-time
 *         description: Timestamp when the diary entry was created.
 *   DiaryEntryInput:
 *     type: object
 *     required:
 *       - mood
 *       - description
 *     properties:
 *       description:
 *         type: string
 *         description: Detailed description of the diary entry.
 *         example: "Had a wonderful day with lots of positive experiences."
 */

/**
 * @swagger
 * /create/{userId}:
 *   post:
 *     tags:
 *       - Diary
 *     summary: Create a new diary entry
 *     description: Creates a new diary entry for the specified user.
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         type: string
 *         description: The ID of the user creating the diary entry.
 *       - in: body
 *         name: diary
 *         description: Diary entry object that needs to be added.
 *         schema:
 *           $ref: '#/definitions/DiaryEntryInput'
 *     responses:
 *       201:
 *         description: Diary entry created successfully.
 *         schema:
 *           $ref: '#/definitions/DiaryEntry'
 *       400:
 *         description: Bad request.
 *       404:
 *         description: User not found.
 */
router.post("/create/:userId", diaryController.createDiary);

/**
 * @swagger
 * /get/{userId}/{diaryId}:
 *   get:
 *     tags:
 *       - Diary
 *     summary: Get a specific diary entry for a user
 *     description: Retrieves a specific diary entry associated with the specified user.
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         type: string
 *         description: The ID of the user whose diary entry is to be fetched.
 *       - in: path
 *         name: diaryId
 *         required: true
 *         type: string
 *         description: The ID of the diary entry to be fetched.
 *     responses:
 *       200:
 *         description: Successfully retrieved diary entry.
 *         schema:
 *           $ref: '#/definitions/DiaryEntry'
 *       404:
 *         description: Diary entry or user not found.
 */
router.get("/get/:userId/:diaryId", diaryController.getDiaryById);

/**
 * @swagger
 * /getAll/{userId}:
 *   get:
 *     tags:
 *       - Diary
 *     summary: Get all diary entries for a user
 *     description: Retrieves all diary entries associated with the specified user.
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         type: string
 *         description: The ID of the user whose diary entries are to be fetched.
 *     responses:
 *       200:
 *         description: Successfully retrieved all diary entries.
 *         schema:
 *           type: array
 *           items:
 *             $ref: '#/definitions/DiaryEntry'
 *       404:
 *         description: User not found.
 */
router.get("/getAll/:userId", diaryController.getDiariesByUser);

/**
 * @swagger
 * /update/{userId}/{diaryId}:
 *   put:
 *     tags:
 *       - Diary
 *     summary: Update a diary entry
 *     description: Updates a specific diary entry identified by diaryId for the given user.
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         type: string
 *         description: The ID of the user updating the diary entry.
 *       - in: path
 *         name: diaryId
 *         required: true
 *         type: string
 *         description: The ID of the diary entry to be updated.
 *       - in: body
 *         name: diary
 *         description: Diary entry object with updated information.
 *         schema:
 *           $ref: '#/definitions/DiaryEntryInput'
 *     responses:
 *       200:
 *         description: Diary entry updated successfully.
 *         schema:
 *           $ref: '#/definitions/DiaryEntry'
 *       400:
 *         description: Bad request.
 *       404:
 *         description: Diary entry or user not found.
 */
router.put("/update/:userId/:diaryId", diaryController.updateDiary);

/**
 * @swagger
 * /delete/{userId}/{diaryId}:
 *   delete:
 *     tags:
 *       - Diary
 *     summary: Delete a diary entry
 *     description: Deletes a specific diary entry identified by diaryId for the specified user.
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         type: string
 *         description: The ID of the user whose diary entry is being deleted.
 *       - in: path
 *         name: diaryId
 *         required: true
 *         type: string
 *         description: The ID of the diary entry to be deleted.
 *     responses:
 *       200:
 *         description: Diary entry deleted successfully.
 *       400:
 *         description: Bad request.
 *       404:
 *         description: Diary entry or user not found.
 */
router.delete("/delete/:userId/:diaryId", diaryController.deleteDiary);

module.exports = router;