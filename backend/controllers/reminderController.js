const reminderService = require('../services/reminderService');

const createReminder = async (req, res) => {
  try {
    const { title, description, date, time, type } = req.body;
    const userId = req.params.userId;
    if (!userId || !title || !date || !time || !type) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    const reminder = await reminderService.createReminder(userId, { title, description, date, time, type });
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
  deleteReminder
};
