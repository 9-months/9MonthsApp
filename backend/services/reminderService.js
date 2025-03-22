/*
 File: reminderService.js
 Purpose: logic for reminder management.
 Created Date: 11-02-2025 CCS-51 Ryan Fernando
 Author: Ryan Fernando

 last modified: [Current Date] | [Your Name] | Updated to new schema
*/

const Reminder = require('../models/Reminder');

class ReminderService {
  // Create a new reminder
  async createReminder(userId, reminderData) {
    try {
      const newReminder = new Reminder({
        userId,
        ...reminderData,
      });
      return await newReminder.save();
    } catch (error) {
      throw new Error('Error creating reminder: ' + error.message);
    }
  }

  // Get all reminders for the user
  async getRemindersByUser(userId) {
    try {
      return await Reminder.find({ userId }).sort({ dateTime: 1 }); // Sort by dateTime
    } catch (error) {
      throw new Error('Error fetching reminders: ' + error.message);
    }
  }

  // Get a specific reminder for the user
  async getReminder(userId, reminderId) {
    try {
      return await Reminder.findOne({ _id: reminderId, userId });
    } catch (error) {
      throw new Error('Error fetching reminder: ' + error.message);
    }
  }

  // Update a specific reminder for the user
  async updateReminder(userId, reminderId, reminderData) {
    try {
      return await Reminder.findOneAndUpdate(
        { _id: reminderId, userId },
        { ...reminderData },
        { new: true }
      );
    } catch (error) {
      throw new Error('Error updating reminder: ' + error.message);
    }
  }

  // Delete a specific reminder for the user
  async deleteReminder(userId, reminderId) {
    try {
      return await Reminder.findOneAndDelete({ _id: reminderId, userId });
    } catch (error) {
      throw new Error('Error deleting reminder: ' + error.message);
    }
  }

  // Get reminders within a time window for notifications
  async getRemindersForNotification(timeWindowStart, timeWindowEnd) {
    try {
      return await Reminder.find({
        dateTime: { $gte: timeWindowStart, $lte: timeWindowEnd },
        isCompleted: false,
      });
    } catch (error) {
      throw new Error('Error fetching reminders for notifications: ' + error.message);
    }
  }
}

module.exports = new ReminderService();