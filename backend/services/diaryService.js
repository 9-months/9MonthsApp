/*
 File: diaryService.js
 Purpose: business logic for the diary.
 Created Date: 2025-02-23 CCS-50 Melissa Joanne
 Author: Melissa Joanne

 last modified: 2025-03-23 | Melissa | CCS-50 diary service updated
*/

const Diary = require("../models/diary");

class DiaryService {
  async createDiaryEntry(userId, description) {
    try {
      const newDiaryEntry = new Diary({ userId, description });
      await newDiaryEntry.save();
      return newDiaryEntry;
    } catch (err) {
      throw new Error(err.message);
    }
  }

  async getDiariesByUserId(userId) {
    try {
      const diaries = await Diary.find({ userId }).sort({ date: -1 });
      return diaries;
    } catch (err) {
      throw new Error(err.message);
    }
  }

  async getDiaryById(userId, diaryId) {
    try {
      const diary = await Diary.findOne({ _id: diaryId, userId });
      return diary;
    } catch (err) {
      throw new Error(err.message);
    }
  }

  async updateDiaryEntry(userId, diaryId, description) {
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
  }

  async deleteDiaryEntry(userId, diaryId) {
    try {
      const deletedDiary = await Diary.findOneAndDelete({ _id: diaryId, userId });
      if (!deletedDiary) {
        throw new Error("Diary entry not found");
      }
      return true;
    } catch (err) {
      throw new Error(err.message);
    }
  }
}

module.exports = new DiaryService();