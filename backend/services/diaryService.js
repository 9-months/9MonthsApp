/*
 File: diaryService.js
 Purpose: business logic for the diary.
 Created Date: 2025-02-23 CCS-50 Melissa Joanne
 Author: Melissa Joanne

 last modified: 2025-02-23 | Melissa | CCS-50 Create Service
*/

const Diary = require("../models/diary");

exports.createOrUpdateDiary = async (userId, moodId, description) => {
  const today = new Date().setHours(0, 0, 0, 0); // Normalize to start of the day

  return await Diary.findOneAndUpdate(
    { userId, date: today }, // Search for existing entry
    { moodId, description, date: today }, // Update or set new values
    { upsert: true, new: true } // Create if not exists, return updated
  );
};

exports.getAllDiaries = async (userId) => {
  return await Diary.find({ userId }).sort({ date: -1 }).populate("moodId");
};

exports.getDiaryById = async (userId, diaryId) => {
  return await Diary.findOne({ _id: diaryId, userId }).populate("moodId");
};

exports.deleteDiary = async (userId, diaryId) => {
  return await Diary.findOneAndDelete({ _id: diaryId, userId });
};
