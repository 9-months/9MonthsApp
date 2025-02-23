/*
 File: diaryController.js
 Purpose: Defines the controller for diary.
 Created Date: 23-02-2025 CCS-50 Melissa Joanne
 Author: Melissa Joanne

 last modified: 11-02-2025 | Dinith | CCS-50 Create Controller
*/

const Diary = require('../models/diary');

// Create a new diary entry
const createDiaryEntry = async (req, res) => {
  const { description } = req.body;
  try {
    const newEntry = new Diary({ description });
    await newEntry.save();
    res.status(201).json({ message: 'Diary entry created successfully!', entry: newEntry });
  } catch (error) {
    res.status(500).json({ message: 'Error creating diary entry', error });
  }
};

// Get all diary entries
const getDiaryEntries = async (req, res) => {
  try {
    const entries = await Diary.find();
    res.status(200).json(entries);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching diary entries', error });
  }
};

// Update a diary entry
const updateDiaryEntry = async (req, res) => {
  const { id } = req.params;
  const { description } = req.body;
  try {
    const updatedEntry = await Diary.findByIdAndUpdate(
      id,
      { description },
      { new: true }
    );
    if (!updatedEntry) {
      return res.status(404).json({ message: 'Diary entry not found' });
    }
    res.status(200).json({ message: 'Diary entry updated successfully!', entry: updatedEntry });
  } catch (error) {
    res.status(500).json({ message: 'Error updating diary entry', error });
  }
};

// Delete a diary entry
const deleteDiaryEntry = async (req, res) => {
  const { id } = req.params;
  try {
    const deletedEntry = await Diary.findByIdAndDelete(id);
    if (!deletedEntry) {
      return res.status(404).json({ message: 'Diary entry not found' });
    }
    res.status(200).json({ message: 'Diary entry deleted successfully!' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting diary entry', error });
  }
};

module.exports = {
  createDiaryEntry,
  getDiaryEntries,
  updateDiaryEntry,
  deleteDiaryEntry,
};
