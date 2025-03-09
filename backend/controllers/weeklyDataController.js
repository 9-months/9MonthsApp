const WeeklyData = require("../models/WeeklyData");

class WeeklyDataController {
  // Get weekly data for a specific week
  async getWeeklyData(req, res) {
    try {
      const { week } = req.params;
      const weeklyData = await WeeklyData.findOne({ week: parseInt(week) });
      
      if (!weeklyData) {
        return res.status(404).json({ message: `No data found for week ${week}` });
      }
      
      res.json(weeklyData);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  // Get only tips for a specific week
  async getTipsForWeek(req, res) {
    try {
      const { week } = req.params;
      const weeklyData = await WeeklyData.findOne({ week: parseInt(week) });
      
      if (!weeklyData) {
        return res.status(404).json({ message: `No tips found for week ${week}` });
      }
      
      // Format the tips as an array of objects with title and content
      const formattedTips = weeklyData.tips.map(tip => {
        return { tip: tip };
      });
      
      res.json(formattedTips);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
}

module.exports = new WeeklyDataController();
