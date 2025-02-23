/*
 File: diaryRoutes.js
 Purpose: Defines routes for diary and swagger documentation.
 Created Date: 23-02-2025 CCS-50 Melissa Joanne
 Author: Melissa Joanne
 

 last modified: 23-02-2025 | Melissa | CCS-50 routes for diary 
*/
const express = require('express');
const router = express.Router();
const { createDiaryEntry, getDiaryEntries, updateDiaryEntry, deleteDiaryEntry } = require('../controllers/diaryController');

// POST: Create a new diary entry
router.post('/', createDiaryEntry);

// GET: Get all diary entries
router.get('/', getDiaryEntries);

// PUT: Update a specific diary entry
router.put('/:id', updateDiaryEntry);

// DELETE: Delete a specific diary entry
router.delete('/:id', deleteDiaryEntry);

module.exports = router;
