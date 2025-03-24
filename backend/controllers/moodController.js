/*
 File: moodController.js
 Purpose: Defines the controller for mood tracking.
 Created Date: 11-02-2025 CCS-48 Dinith Perera
 Author: Dinith Perera

 last modified: 24-03-2025 | Dinith | Performance optimization
*/

const moodService = require('../services/moodService');

module.exports = {

  // Create a new mood entry 
  createMoodEntry: async (req, res) => {
    try {
      const { mood, note } = req.body;
      const userId = req.params.userId;
      
      if (!mood) {
        return res.status(400).json({ error: 'Mood is required' });
      }
      
      const moodEntry = await moodService.createMoodEntry(userId, { mood, note });
      res.status(201).json(moodEntry);
    } catch (error) {
      console.error('Error creating mood entry:', error);
      res.status(500).json({ error: 'Failed to create mood entry' });
    }
  },

  // Get all mood entries for the user with pagination
  getMoodEntries: async (req, res) => {
    try {
      const userId = req.params.userId;
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 20;
      
      // Validate pagination parameters
      if (page < 1 || limit < 1 || limit > 100) {
        return res.status(400).json({ error: 'Invalid pagination parameters' });
      }
      
      const entries = await moodService.getMoodEntries(userId, page, limit);
      res.status(200).json(entries);
    } catch (error) {
      console.error('Error fetching mood entries:', error);
      res.status(500).json({ error: 'Failed to fetch mood entries' });
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
      console.error('Error fetching mood entry:', error);
      res.status(500).json({ error: 'Failed to fetch mood entry' });
    }
  },

  // Update a specific mood entry for the user
  updateMoodEntry: async (req, res) => {
    try {
      const { mood, note } = req.body;
      const { userId, moodId } = req.params;
      
      if (!mood) {
        return res.status(400).json({ error: 'Mood is required' });
      }
      
      const updatedMood = await moodService.updateMoodEntry(userId, moodId, { mood, note });
      
      if (!updatedMood) {
        return res.status(404).json({ error: 'Mood entry not found' });
      }
      
      res.status(200).json(updatedMood);
    } catch (error) {
      console.error('Error updating mood entry:', error);
      res.status(500).json({ error: 'Failed to update mood entry' });
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
      console.error('Error deleting mood entry:', error);
      res.status(500).json({ error: 'Failed to delete mood entry' });
    }
  }
};