const moodService = require('../services/moodService');

module.exports = {
  createMoodEntry: async (req, res) => {
    try {
      const { mood, note } = req.body;
      const userId = req.user.uid; // Assuming you have authentication middleware
      
      const moodEntry = await moodService.createMoodEntry(userId, { mood, note });
      res.status(201).json(moodEntry);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  getMoodEntries: async (req, res) => {
    try {
      const userId = req.user.uid; // Assuming you have authentication middleware
      const entries = await moodService.getMoodEntries(userId);
      res.status(200).json(entries);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
};