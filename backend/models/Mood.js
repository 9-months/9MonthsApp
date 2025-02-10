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