const WeeklyData = require("../models/WeeklyData");

class WeeklyDataController {
  // Get weekly data for a specific week
  async getWeeklyData(req, res) {
    try {
      const { week } = req.params;
      console.log(`Fetching weekly data for week: ${week}`);
      const weeklyData = await WeeklyData.findOne({ week: parseInt(week) });
      
      if (!weeklyData) {
        console.log(`No data found for week: ${week}`);
        return res.status(404).json({ message: `No data found for week ${week}` });
      }
      
      console.log(`Weekly data for week ${week}:`, weeklyData);
      res.json(weeklyData);
    } catch (error) {
      console.error(`Error fetching weekly data for week ${week}:`, error);
      res.status(500).json({ error: error.message });
    }
  }

  // Get only tips for a specific week
  async getTipsForWeek(req, res) {
    try {
      const { week } = req.params;
      console.log(`Fetching tips for week: ${week}`);
      const weeklyData = await WeeklyData.findOne({ week: parseInt(week) });
      
      if (!weeklyData) {
        console.log(`No tips found for week: ${week}`);
        return res.status(404).json({ message: `No tips found for week ${week}` });
      }
      
      // Format the tips as an array of objects with tip property
      const formattedTips = weeklyData.tips.map(tip => {
        return { tip };
      });
      
      console.log(`Tips for week ${week}:`, formattedTips);
      res.json(formattedTips);
    } catch (error) {
      console.error(`Error fetching tips for week ${week}:`, error);
      res.status(500).json({ error: error.message });
    }
  }
}

module.exports = new WeeklyDataController();
