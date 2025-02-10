const Mood = require('../models/Mood');

class MoodService {
  async createMoodEntry(userId, moodData) {
    try {
      const newMood = new Mood({
        userId,
        ...moodData
      });
      return await newMood.save();
    } catch (error) {
      throw new Error('Error creating mood entry: ' + error.message);
    }
  }

  async getMoodEntries(userId) {
    try {
      return await Mood.find({ userId }).sort({ date: -1 });
    } catch (error) {
      throw new Error('Error fetching mood entries: ' + error.message);
    }
  }
}

module.exports = new MoodService();