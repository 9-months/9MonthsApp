/*
 File: moodController.js
 Purpose: Defines the controller for mood tracking.
 Created Date: 11-02-2025 CCS-48 Dinith Perera
 Author: Dinith Perera

 last modified: 11-02-2025 | Dinith | CCS-48 Create Controller
*/

const moodService = require('../services/moodService');

module.exports = {

  // Create a new mood entry 
  createMoodEntry: async (req, res) => {
    try {
      const { mood, note } = req.body;
      const userId = req.params.userId; 
      
      const moodEntry = await moodService.createMoodEntry(userId, { mood, note });
      res.status(201).json(moodEntry);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Get all mood entries for the user
  getMoodEntries: async (req, res) => {
    try {
      const userId = req.params.userId; 
      const entries = await moodService.getMoodEntries(userId);
      res.status(200).json(entries);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Get a specific mood entry for the user
  getMoodEntry: async (req, res) => {
    try {
      const { userId, moodId } = req.params;
      const entry = await moodService.getMoodEntry(userId, moodId);
      if (!entry) {
        return res.status(404).json({ error: 'Mood entry not found' });
      }
      res.status(200).json(entry);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Update a specific mood entry for the user
  updateMoodEntry: async (req, res) => {
    try {
      const { mood, note } = req.body;
      const { userId, moodId } = req.params;
      
      const updatedMood = await moodService.updateMoodEntry(userId, moodId, { mood, note });
      if (!updatedMood) {
        return res.status(404).json({ error: 'Mood entry not found' });
      }
      res.status(200).json(updatedMood);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Delete a specific mood entry for the user
  deleteMoodEntry: async (req, res) => {
    try {
      const { userId, moodId } = req.params;
      
      const deletedMood = await moodService.deleteMoodEntry(userId, moodId);
      if (!deletedMood) {
        return res.status(404).json({ error: 'Mood entry not found' });
      }
      res.status(200).json({ message: 'Mood entry successfully deleted' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
};