const mongoose = require('mongoose');

const ReminderSchema = new mongoose.Schema({
  userId: {
    type: String, // Changed from ObjectId to String
    required: true
    
  },
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    maxLength: 500
  },
  location: {
    type: String,
  },
  dateTime: {
    type: String, 
    required: true
  },
  timezone: {
    type: String,
    required: true,
  },
  repeat: {
    type: String,
    enum: ['none', 'daily', 'weekly', 'monthly', 'yearly'],
    default: 'none'
  },
  alertOffsets: [{type: Number}],
  type: {
    type: String,
    enum: ['medicine', 'appointment', 'other'],
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  isCompleted: {
    type: Boolean,
    default: false
  },
}, {
  collection: 'reminders'
});

module.exports = mongoose.model('Reminder', ReminderSchema);