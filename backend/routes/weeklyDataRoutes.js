const express = require("express");
const WeeklyDataController = require("../controllers/weeklyDataController");
const router = express.Router();

// Get weekly data for a specific week
router.get("/week/:week", WeeklyDataController.getWeeklyData);

// Get only tips for a specific week
router.get("/week/:week/tips", WeeklyDataController.getTipsForWeek);

module.exports = router;
