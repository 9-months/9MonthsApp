/*
 File: pregnancyRouter.js
 Purpose: Defines routes for pregnancy-tracker and swagger documentation.
 Created Date: 2025-02-08 CCS-8 Chamod Kamiss
 Author: Chamod Kamiss
 swagger doc: Melissa Joanne 

 last modified: 2025-03-15 | Chamod | CCS-8 Swagger API documrntation 
*/
const express = require("express");
const PregnancyController = require("../controllers/pregnancyController");
const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Pregnancy
 *   description: Pregnancy tracking API
 */

/**
 * @swagger
 * /pregnancy:
 *   post:
 *     summary: Create a pregnancy record
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
 *                 example: "12345"
 *               dueDate:
 *                 type: string
 *                 format: date
 *                 example: "2025-12-01"
 *     responses:
 *       201:
 *         description: Pregnancy record created successfully
 *       500:
 *         description: Internal server error
 */
router.post("/", PregnancyController.createPregnancy);

/**
 * @swagger
 * /pregnancy/{userId}:
 *   get:
 *     summary: Get pregnancy details
 *     tags: [Pregnancy]
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Pregnancy details retrieved successfully
 *       404:
 *         description: Pregnancy data not found
 *       500:
 *         description: Internal server error
 */
router.get("/:userId", PregnancyController.getPregnancy);

/**
 * @swagger
 * /pregnancy/{userId}:
 *   put:
 *     summary: Update pregnancy details
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
 *                 example: "2025-11-20"
 *     responses:
 *       200:
 *         description: Pregnancy record updated successfully
 *       404:
 *         description: Pregnancy data not found
 *       500:
 *         description: Internal server error
 */
router.put("/:userId", PregnancyController.updatePregnancy);

/**
 * @swagger
 * /pregnancy/{userId}:
 *   delete:
 *     summary: Delete pregnancy record
 *     tags: [Pregnancy]
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Pregnancy data deleted successfully
 *       404:
 *         description: Pregnancy data not found
 *       500:
 *         description: Internal server error
 */
router.delete("/:userId", PregnancyController.deletePregnancy);

module.exports = router;
