/*
 File: moodService.js
 Purpose: logic for mood tracking.
 Created Date: 11-02-2025 CCS-48 Dinith Perera
 Author: Dinith Perera

 last modified: 11-02-2025 | Dinith | CCS-48 Create Service
*/

const Mood = require('../models/Mood');

class MoodService {

  // create a new mood entry
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

  // get all mood entries for the user
  async getMoodEntries(userId) {
    try {
      return await Mood.find({ userId }).sort({ date: -1 });
    } catch (error) {
      throw new Error('Error fetching mood entries: ' + error.message);
    }
  }

  // get a specific mood entry for the user
  async getMoodEntry(userId, moodId) {
    try {
      return await Mood.findOne({ _id: moodId, userId });
    } catch (error) {
      throw new Error('Error fetching mood entry: ' + error.message);
    }
  }

  // update a specific mood entry for the user
  async updateMoodEntry(userId, moodId, moodData) {
    try {
      return await Mood.findOneAndUpdate(
        { _id: moodId, userId },
        { ...moodData },
        { new: true }
      );
    } catch (error) {
      throw new Error('Error updating mood entry: ' + error.message);
    }
  }

  // delete a specific mood entry for the user
  async deleteMoodEntry(userId, moodId) {
    try {
      return await Mood.findOneAndDelete({ _id: moodId, userId });
    } catch (error) {
      throw new Error('Error deleting mood entry: ' + error.message);
    }
  }
}

module.exports = new MoodService();