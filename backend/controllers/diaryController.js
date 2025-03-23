/*
 File: diaryController.js
 Purpose: Defines the controller for diary.
 Created Date: 23-02-2025 CCS-50 Melissa Joanne
 Author: Melissa Joanne

 last modified: 21-03-2025 | Melissa | CCS-50 updated error messages
*/
const diaryService = require("../services/diaryService");

class DiaryController {
  // CREATE: Add a new diary entry
  async createDiary(req, res) {
    try {
      const { userId } = req.params; // Get userId from URL
      const { description } = req.body; // User provides description

      // Input validation
      if (!description || description.trim() === "") {
        return res.status(400).json({ message: "Description is required" });
      }

      const newDiaryEntry = await diaryService.createDiaryEntry(userId, description);
      res.status(201).json({ message: "Diary entry created successfully", newDiaryEntry });
    } catch (err) {
      console.error("Error creating diary entry:", err); 
      res.status(500).json({ message: "Server error while creating diary entry", error: err.message });
    }
  }

  // READ: Get a specific diary entry for a user
  async getDiaryById(req, res) {
    try {
      const { userId, diaryId } = req.params; 

      // Call the service to get the diary entry
      const diary = await diaryService.getDiaryById(userId, diaryId);

      // If the diary entry is not found, return 404
      if (!diary) {
        return res.status(404).json({ message: "Diary entry not found" });
      }

      res.status(200).json(diary);
    } catch (err) {
      console.error("Error retrieving diary entry:", err); // Log the error for debugging
      // Handle database or other unexpected errors
      if (err.name === 'MongoError') {
        return res.status(500).json({ message: "Database error occurred", error: err.message });
      }
      res.status(500).json({ message: "Server error while retrieving diary entry", error: err.message });
    }
  }

  // READ: Get all diary entries for a user
  async getDiariesByUser(req, res) {
    try {
      const { userId } = req.params; // Get userId from URL
      const diaries = await diaryService.getDiariesByUserId(userId);

      if (!diaries || diaries.length === 0) {
        return res.status(404).json({ message: "No diary entries found for this user" });
      }

      res.status(200).json(diaries);
    } catch (err) {
      console.error("Error retrieving diaries:", err); 
      res.status(500).json({ message: "Server error while retrieving diaries", error: err.message });
    }
  }

  // UPDATE: Update an existing diary entry by its ID
  async updateDiary(req, res) {
    try {
      const { userId, diaryId } = req.params; 
      const { description } = req.body; 

      // Input validation
      if (!description || description.trim() === "") {
        return res.status(400).json({ message: "Updated description is required" });
      }

      const updatedDiary = await diaryService.updateDiaryEntry(userId, diaryId, description);
      if (!updatedDiary) {
        return res.status(404).json({ message: "Diary entry not found" });
      }

      res.status(200).json({ message: "Diary entry updated", updatedDiary });
    } catch (err) {
      console.error("Error updating diary entry:", err); 
      res.status(500).json({ message: "Server error while updating diary entry", error: err.message });
    }
  }

  // DELETE: Delete a diary entry
  async deleteDiary(req, res) {
    try {
      const { userId, diaryId } = req.params; 

      const deletedDiary = await diaryService.deleteDiaryEntry(userId, diaryId);
      if (!deletedDiary) {
        return res.status(404).json({ message: "Diary entry not found" });
      }

      res.status(200).json({ message: "Diary entry deleted successfully" });
    } catch (err) {
      console.error("Error deleting diary entry:", err); 
      res.status(500).json({ message: "Server error while deleting diary entry", error: err.message });
    }
  }
}


module.exports = new DiaryController();