/*
 File: diaryService.js
 Purpose: business logic for the diary.
 Created Date: 2025-02-23 CCS-50 Melissa Joanne
 Author: Melissa Joanne

 last modified: 2025-02-23 | Melissa | CCS-50 Create Service
*/

// diaryService.js
// Purpose: Handles all the logic for interacting with the Diary model
// Created Date: 23-02-2025 CCS-50 Melissa Joanne
// Author: Melissa Joanne

const Diary = require("../models/diary");

const createDiaryEntry = async (userId, description) => {
  try {
    const newDiaryEntry = new Diary({ userId, description });
    await newDiaryEntry.save();
    return newDiaryEntry;
  } catch (err) {
    throw new Error(err.message);
  }
};

const getDiariesByUserId = async (userId) => {
  try {
    const diaries = await Diary.find({ userId }).sort({ date: -1 });
    return diaries;
  } catch (err) {
    throw new Error(err.message);
  }
};

const getAllDiaries = async () => {
  try {
    const diaries = await Diary.find().sort({ date: -1 });
    return diaries;
  } catch (err) {
    throw new Error(err.message);
  }
};

const updateDiaryEntry = async (userId, diaryId, description) => {
  try {
    const updatedDiary = await Diary.findOneAndUpdate(
      { _id: diaryId, userId },
      { description, date: Date.now() },
      { new: true }
    );
    if (!updatedDiary) {
      throw new Error("Diary entry not found");
    }
    return updatedDiary;
  } catch (err) {
    throw new Error(err.message);
  }
};

const deleteDiaryEntry = async (userId, diaryId) => {
  try {
    const deletedDiary = await Diary.findOneAndDelete({ _id: diaryId, userId });
    if (!deletedDiary) {
      throw new Error("Diary entry not found");
    }
    return true;
  } catch (err) {
    throw new Error(err.message);
  }
};

module.exports = {
  createDiaryEntry,
  getDiariesByUserId,
  getAllDiaries,
  updateDiaryEntry,
  deleteDiaryEntry,
};