/*
 File: emergencyRouter.js
 Purpose: Defines routes for emergency btn and swagger documentation.
 Created Date: 2025-02-03 CCS-9 Dinith Perera
 Author: Dinith Perera
 swagger doc: Melissa Joanne 

 last modified: 2025-02-03 | Dinith | CCS-9 Create Controllers 
*/

const express = require('express');
const emergencyController = require('./emergencyController');

const router = express.Router();

router.post('/emergency', (req, res) => emergencyController.handleEmergencyRequest(req, res));

module.exports = router;