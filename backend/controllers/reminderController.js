/*
 File: reminderController.js
 Purpose: Controllers for reminder.
 Created Date: 11-02-2025 CCS-51 Ryan Fernando
 Author: Ryan Fernando

 last modified: [Current Date] | [Your Name] | Updated for new schema and service
*/

const reminderService = require('../services/reminderService');

const createReminder = async (req, res) => {
  try {
    const {
      title,
      description,
      dateTime,
      timezone,
      repeat,
      alertOffsets,
      type,
      location,
    } = req.body;
    const userId = req.params.userId;

    if (!userId || !title || !dateTime || !timezone || !type) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const reminder = await reminderService.createReminder(userId, {
      title,
      description,
      dateTime,
      timezone,
      repeat,
      alertOffsets,
      type,
      location,
    });
    res.status(201).json(reminder);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const getRemindersByUser = async (req, res) => {
  try {
    const reminders = await reminderService.getRemindersByUser(req.params.userId);
    res.status(200).json(reminders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const getReminder = async (req, res) => {
  try {
    const reminder = await reminderService.getReminder(req.params.userId, req.params.reminderId);
    res.status(200).json(reminder);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const updateReminder = async (req, res) => {
  try {
    const reminder = await reminderService.updateReminder(req.params.userId, req.params.reminderId, req.body);
    res.status(200).json(reminder);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const deleteReminder = async (req, res) => {
  try {
    await reminderService.deleteReminder(req.params.userId, req.params.reminderId);
    res.status(200).json({ message: 'Reminder deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = {
  createReminder,
  getRemindersByUser,
  getReminder,
  updateReminder,
  deleteReminder,
};