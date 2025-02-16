/*
 File: reminderService.js
 Purpose: logic for reminder management.
 Created Date: 11-02-2025 CCS-48 Dinith Perera
 Author: Dinith Perera

 last modified: 11-02-2025 | Dinith | CCS-48 Create Service
*/

const Reminder = require('../models/Reminder');

class ReminderService {

  // create a new reminder
  async createReminder(userId, reminderData) {
    try {
      const newReminder = new Reminder({
        userId,
        ...reminderData
      });
      return await newReminder.save();
    } catch (error) {
      throw new Error('Error creating reminder: ' + error.message);
    }
  }

  // get all reminders for the user
  async getRemindersByUser(userId) {
    try {
      return await Reminder.find({ userId }).sort({ date: -1 });
    } catch (error) {
      throw new Error('Error fetching reminders: ' + error.message);
    }
  }

  // get a specific reminder for the user
  async getReminder(userId, reminderId) {
    try {
      return await Reminder.findOne({ _id: reminderId, userId });
    } catch (error) {
      throw new Error('Error fetching reminder: ' + error.message);
    }
  }

  // update a specific reminder for the user
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

  // delete a specific reminder for the user
  async deleteReminder(userId, reminderId) {
    try {
      return await Reminder.findOneAndDelete({ _id: reminderId, userId });
    } catch (error) {
      throw new Error('Error deleting reminder: ' + error.message);
    }
  }
}

module.exports = new ReminderService();
