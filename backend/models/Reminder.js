/*
 File: Reminder.js
 Purpose: Defines the schema for Reminders.
 Created Date: 13-02-2025 CCS-48 Ryan Fernando
 Author: Ryan Fernando

 last modified: 14-02-2025 | Ryan | CCS-56 Create Reminder Schema
*/
const mongoose = require('mongoose');

const ReminderSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    ref: 'User'
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
    type: String
  },
  date: {
    type: Date,
    required: true
  },
  time: {
    type: String,
    required: true
  },
  repeat: {
    type: String,
    enum: ['none', 'daily', 'weekly', 'monthly', 'yearly'],
    default: 'none'
  },
  alert: {
    type: String,
    enum: ['none', 'at time of event', '5 minutes before', '15 minutes before', '30 minutes before', '1 hour before', '1 day before'],
    default: 'none'
  },
  type: {
    type: String,
    enum: ['medicine', 'appointment', 'other'],
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
}, {
  collection: 'reminders'
});

module.exports = mongoose.model('Reminder', ReminderSchema);
