/*
 File: diaryController.js
 Purpose: Defines the controller for diary.
 Created Date: 23-02-2025 CCS-50 Melissa Joanne
 Author: Melissa Joanne

 last modified: 11-02-2025 | Dinith | CCS-50 Create Controller
*/
const Diary = require("../models/diary");

// CREATE: Add a new diary entry
exports.createDiary = async (req, res) => {
  try {
    const { userId } = req.params; // Get userId from URL
    const { description } = req.body; // User provides description

    const newDiaryEntry = new Diary({
      userId,
      description
    });

    await newDiaryEntry.save();
    res.status(201).json({ message: "Diary entry created successfully", newDiaryEntry });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// READ: Get all diary entries for a user
exports.getDiariesByUser = async (req, res) => {
  try {
    const { userId } = req.params; // Get userId from URL
    const diaries = await Diary.find({ userId }).sort({ date: -1 });
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

    const updatedDiary = await Diary.findOneAndUpdate(
      { _id: diaryId, userId }, // Ensure it's the correct user and entry
      { description, date: Date.now() }, // Automatically update date
      { new: true }
    );

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

    const deletedDiary = await Diary.findOneAndDelete({ _id: diaryId, userId });

    if (!deletedDiary) {
      return res.status(404).json({ message: "Diary entry not found" });
    }

    res.status(200).json({ message: "Diary entry deleted" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

  exports.getAllDiaries = async (req, res) => {
    try {
      const diaries = await Diary.find();
      res.status(200).json(diaries);
    } catch (error) {
      res.status(500).json({ message: 'Error retrieving diaries', error });
    }
  };
