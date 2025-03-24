/*
 File: moodService.js
 Purpose: logic for mood tracking.
 Created Date: 11-02-2025 CCS-48 Dinith Perera
 Author: Dinith Perera

 last modified: 11-02-2025 | Dinith | CCS-48 Create Service
               2026-01-10 | Performance optimization
*/

const Mood = require('../models/Mood');
const NodeCache = require('node-cache'); // You'll need to install this package

// Simple in-memory cache with 5-minute TTL
const moodCache = new NodeCache({ stdTTL: 300 });

class MoodService {

  // create a new mood entry
  async createMoodEntry(userId, moodData) {
    try {
      const newMood = new Mood({
        userId,
        ...moodData
      });
      const savedMood = await newMood.save();
      
      // Invalidate user's mood cache when a new entry is added
      moodCache.del(`moods_${userId}`);
      
      return savedMood;
    } catch (error) {
      throw new Error('Error creating mood entry: ' + error.message);
    }
  }

  // get all mood entries for the user with pagination
  async getMoodEntries(userId, page = 1, limit = 20) {
    try {
      const cacheKey = `moods_${userId}_${page}_${limit}`;
      const cachedMoods = moodCache.get(cacheKey);
      
      if (cachedMoods) {
        return cachedMoods;
      }
      
      const skip = (page - 1) * limit;
      
      // Use lean() for better performance when you don't need mongoose document methods
      const moods = await Mood.find({ userId })
        .sort({ date: -1 })
        .skip(skip)
        .limit(limit)
        .lean()
        .exec();
      
      // Cache the results
      moodCache.set(cacheKey, moods);
      
      return moods;
    } catch (error) {
      throw new Error('Error fetching mood entries: ' + error.message);
    }
  }

  // get a specific mood entry for the user
  async getMoodEntry(userId, moodId) {
    try {
      const cacheKey = `mood_${userId}_${moodId}`;
      const cachedMood = moodCache.get(cacheKey);
      
      if (cachedMood) {
        return cachedMood;
      }
      
      const mood = await Mood.findOne({ _id: moodId, userId }).lean().exec();
      
      if (mood) {
        moodCache.set(cacheKey, mood);
      }
      
      return mood;
    } catch (error) {
      throw new Error('Error fetching mood entry: ' + error.message);
    }
  }

  // update a specific mood entry for the user
  async updateMoodEntry(userId, moodId, moodData) {
    try {
      const updatedMood = await Mood.findOneAndUpdate(
        { _id: moodId, userId },
        { $set: moodData }, // Use $set operator explicitly
        { new: true, lean: true } // Return the updated document and use lean for better performance
      );
      
      // Update the cache
      if (updatedMood) {
        const cacheKey = `mood_${userId}_${moodId}`;
        moodCache.set(cacheKey, updatedMood);
        
        // Invalidate the list cache
        moodCache.del(`moods_${userId}`);
      }
      
      return updatedMood;
    } catch (error) {
      throw new Error('Error updating mood entry: ' + error.message);
    }
  }

  // delete a specific mood entry for the user
  async deleteMoodEntry(userId, moodId) {
    try {
      const deletedMood = await Mood.findOneAndDelete({ _id: moodId, userId });
      
      // Invalidate caches if the mood was found and deleted
      if (deletedMood) {
        moodCache.del(`mood_${userId}_${moodId}`);
        moodCache.del(`moods_${userId}`);
      }
      
      return deletedMood;
    } catch (error) {
      throw new Error('Error deleting mood entry: ' + error.message);
    }
  }
}

module.exports = new MoodService();