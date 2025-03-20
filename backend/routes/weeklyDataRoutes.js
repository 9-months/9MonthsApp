const express = require("express");
const WeeklyDataController = require("../controllers/weeklyDataController");
const router = express.Router();

/**
 * @swagger
 * /week/{week}:
 *   get:
 *     summary: Get weekly data for a specific week
 *     parameters:
 *       - in: path
 *         name: week
 *         required: true
 *         schema:
 *           type: integer
 *         description: The week number
 *     responses:
 *       200:
 *         description: Weekly data retrieved successfully
 *       400:
 *         description: Invalid week number
 *       404:
 *         description: Weekly data not found
 */

/**
 * @swagger
 * /week/{week}/tips:
 *   get:
 *     summary: Get only tips for a specific week
 *     parameters:
 *       - in: path
 *         name: week
 *         required: true
 *         schema:
 *           type: integer
 *         description: The week number
 *     responses:
 *       200:
 *         description: Tips retrieved successfully
 *       400:
 *         description: Invalid week number
 *       404:
 *         description: Tips not found
 */
// Get weekly data for a specific week
router.get("/week/:week", WeeklyDataController.getWeeklyData);

// Get only tips for a specific week
router.get("/week/:week/tips", WeeklyDataController.getTipsForWeek);

module.exports = router;
