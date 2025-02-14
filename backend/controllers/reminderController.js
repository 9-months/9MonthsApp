const reminderService = require('../services/reminderService');

const createReminder = async (req, res) => {
  try {
    const { userId, title, date, time, type } = req.body;
    if (!userId || !title || !date || !time || !type) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    const reminder = await reminderService.createReminder(req.body);
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

const updateReminder = async (req, res) => {
  try {
    const reminder = await reminderService.updateReminder(req.params.id, req.body);
    res.status(200).json(reminder);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const deleteReminder = async (req, res) => {
  try {
    await reminderService.deleteReminder(req.params.id);
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = {
  createReminder,
  getRemindersByUser,
  updateReminder,
  deleteReminder
};
