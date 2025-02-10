/*
 File: Mood.js
 Purpose: Defines the schema for mood tracking.
 Created Date: 11-02-2025 CCS-48 Dinith Perera
 Author: Dinith Perera

 last modified: 11-02-2025 | Dinith | CCS-48 Create Schema
*/

const mongoose = require('mongoose');

const MoodSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    ref: 'User'
  },
  mood: {
    type: String,
    required: true,
    enum: ['happy', 'sad', 'anxious', 'calm', 'stressed', 'excited']
  },
  note: {
    type: String,
    maxLength: 500
  },
  date: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Mood', MoodSchema);