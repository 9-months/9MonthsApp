/*
 File: pregnancyRouter.js
 Purpose: Defines routes for pregnancy-tracker and swagger documentation.
 Created Date: 2025-02-08 CCS-8 Chamod Kamiss
 Author: Chamod Kamiss
 swagger doc: Melissa Joanne 

 last modified: 2025-02-08 | Chamod | CCS-8 Create routes for pregnancy tracker
*/

const express = require("express");
const PregnancyController = require("../controllers/pregnancyController");
const { verifyToken } = require('../middleware/authMiddleware');
const router = express.Router();

/**
 * @swagger
 * /:
 *   post:
 *     summary: Create a new pregnancy record
 *     tags: [Pregnancy]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               userId:
 *                 type: string
 *               dueDate:
 *                 type: string
 *                 format: date
 *               notes:
 *                 type: string
 *     responses:
 *       201:
 *         description: Pregnancy record created successfully
 *       400:
 *         description: Bad request
 * 
 * /{userId}:
 *   get:
 *     summary: Get pregnancy record by user ID
 *     tags: [Pregnancy]
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Pregnancy record retrieved successfully
 *       404:
 *         description: Pregnancy record not found
 * 
 *   put:
 *     summary: Update pregnancy record by user ID
 *     tags: [Pregnancy]
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               dueDate:
 *                 type: string
 *                 format: date
 *               notes:
 *                 type: string
 *     responses:
 *       200:
 *         description: Pregnancy record updated successfully
 *       400:
 *         description: Bad request
 *       404:
 *         description: Pregnancy record not found
 * 
 *   delete:
 *     summary: Delete pregnancy record by user ID
 *     tags: [Pregnancy]
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Pregnancy record deleted successfully
 *       404:
 *         description: Pregnancy record not found
 */

router.post("/", verifyToken, PregnancyController.createPregnancy);
router.get("/:userId", PregnancyController.getPregnancy);
router.put("/:userId", verifyToken, PregnancyController.updatePregnancy);
router.delete("/:userId", verifyToken, PregnancyController.deletePregnancy);


module.exports = router;
