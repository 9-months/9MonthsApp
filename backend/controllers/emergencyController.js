/*
 File: emergencyController.js
 Purpose: Handles Handles HTTP requests for emergency button.
 Created Date: 2025-02-03 CCS-9 Dinith Perera
 Author: Dinith Perera

 last modified: 2025-02-03 | Dinith | CCS-9 Create Controller
*/

const emergencyService = require('../services/emergencyService');

class EmergencyController {
    async handleEmergencyRequest(req, res) {
        try {
            const data = req.body;
            const result = await emergencyService.handleEmergencyCall(data);
            res.status(200).json(result);
        } catch (error) {
            res.status(500).json({ status: "error", message: error.message });
        }
    }
}

module.exports = new EmergencyController();