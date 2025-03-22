const express = require("express");
const WeeklyDataController = require("../controllers/weeklyDataController");
const { verifyToken } = require('../middleware/authMiddleware');
const router = express.Router();

// Get weekly data for a specific week
router.get("/week/:week", verifyToken, WeeklyDataController.getWeeklyData);

// Get only tips for a specific week
router.get("/week/:week/tips", verifyToken, WeeklyDataController.getTipsForWeek);

module.exports = router;
