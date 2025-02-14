const Reminder = require('../models/Reminder');

const createReminder = async (reminderData) => {
  const reminder = new Reminder(reminderData);
  return await reminder.save();
};

const getRemindersByUser = async (userId) => {
  return await Reminder.find({ userId });
};

const updateReminder = async (reminderId, reminderData) => {
  return await Reminder.findByIdAndUpdate(reminderId, reminderData, { new: true });
};

const deleteReminder = async (reminderId) => {
  return await Reminder.findByIdAndDelete(reminderId);
};

module.exports = {
  createReminder,
  getRemindersByUser,
  updateReminder,
  deleteReminder
};
