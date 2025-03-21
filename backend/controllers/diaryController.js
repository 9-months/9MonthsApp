/*
 File: diaryController.js
 Purpose: Defines the controller for diary.
 Created Date: 23-02-2025 CCS-50 Melissa Joanne
 Author: Melissa Joanne

 last modified: 11-02-2025 | Dinith | CCS-50 Create Controller
*/
const Diary = require("../models/diary");
const diaryService = require("../services/diaryService");
const mongoose = require("mongoose");

// CREATE: Add a new diary entry
exports.createDiary = async (req, res) => {
  try {
    const { userId } = req.params; // Get userId from URL
    const { description } = req.body; // User provides description

    // Validate if description is provided
    if (!description) {
      return res.status(400).json({ message: "Description is required" });
    }

    const newDiaryEntry = await diaryService.createDiaryEntry(userId, description);
    res.status(201).json({ message: "Diary entry created successfully", newDiaryEntry });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// READ: Get a specific diary entry for a user
exports.getDiaryById = async (req, res) => {
  try {
    const { userId, diaryId } = req.params; // Get userId and diaryId from URL

    // Check if diaryId is a valid ObjectId
    if (!mongoose.Types.ObjectId.isValid(diaryId)) {
      return res.status(400).json({ message: "Invalid diary ID" });
    }

    const diary = await diaryService.getDiaryById(userId, diaryId);
    if (!diary) {
      return res.status(404).json({ message: "Diary entry not found" });
    }

    res.status(200).json(diary);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// READ: Get all diary entries for a user
exports.getDiariesByUser = async (req, res) => {
  try {
    const { userId } = req.params; // Get userId from URL
    const diaries = await diaryService.getDiariesByUserId(userId);
    res.status(200).json(diaries);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// UPDATE: Update an existing diary entry by its ID
exports.updateDiary = async (req, res) => {
  try {
    const { userId, diaryId } = req.params; // Get userId and diaryId from URL
    const { description } = req.body; // User provides updated description

    // Validate if description is provided
    if (!description) {
      return res.status(400).json({ message: "Description is required" });
    }

    const updatedDiary = await diaryService.updateDiaryEntry(userId, diaryId, description);
    if (!updatedDiary) {
      return res.status(404).json({ message: "Diary entry not found" });
    }

    res.status(200).json({ message: "Diary entry updated", updatedDiary });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// DELETE: Delete a diary entry
exports.deleteDiary = async (req, res) => {
  try {
    const { userId, diaryId } = req.params; // Get userId and diaryId from URL

    // Check if diaryId is a valid ObjectId
    if (!mongoose.Types.ObjectId.isValid(diaryId)) {
      return res.status(400).json({ message: "Invalid diary ID" });
    }

    const deletedDiary = await diaryService.deleteDiaryEntry(userId, diaryId);
    if (!deletedDiary) {
      return res.status(404).json({ message: "Diary entry not found" });
    }

    res.status(200).json({ message: "Diary entry deleted" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
