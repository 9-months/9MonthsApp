/*
 File: diaryRoutes.js
 Purpose: Defines routes for diary and swagger documentation.
 Created Date: 23-02-2025 CCS-50 Melissa Joanne
 Author: Melissa Joanne
 

 last modified: 23-02-2025 | Melissa | CCS-50 routes for diary 
*/
const express = require("express");
const router = express.Router();
const diaryController = require("../controllers/diaryController");

// Route for creating a new diary entry
router.post("/create/:userId", diaryController.createDiary);

// Route for getting all diary entries of a user
router.get("/:userId", diaryController.getDiariesByUser);

// Route for updating a specific diary entry
router.put("/update/:userId/:diaryId", diaryController.updateDiary);

// Route for deleting a specific diary entry
router.delete("/delete/:userId/:diaryId", diaryController.deleteDiary);

module.exports = router;

