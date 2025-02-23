/*
 File: diary.js
 Purpose: Defines the schema for diary.
 Created Date: 23-02-2025 CCS-50 Melissa Joanne
 Author: Melissa Joanne

 last modified: 23-02-2025 | Melissa | CCS-50 Create Schema
*/
const mongoose = require('mongoose');

const diarySchema = new mongoose.Schema({
  description: {
    type: String,
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

const Diary = mongoose.model('Diary', diarySchema);

module.exports = Diary;
