/*
 File: partnerController.js
 Purpose: Controller for partner-related operations
 Created Date: 2025-03-17
 Author: Irosh Perera
*/

const partnerService = require('../services/partnerService');
const User = require('../models/User');

// Controller for partner operations
const partnerController = {
  // Link a partner account with a mother account
  async linkPartner(req, res) {
    try {
      const { uid, linkCode } = req.body;
      
      if (!uid || !linkCode) {
        return res.status(400).json({
          status: false,
          message: "Partner ID and link code are required."
        });
      }
      
      const result = await partnerService.linkPartnerWithMother(uid, linkCode);
      
      if (result.status) {
        return res.status(200).json(result);
      } else {
        return res.status(400).json(result);
      }
    } catch (error) {
      console.error("Error linking partner:", error);
      return res.status(500).json({
        status: false,
        message: "Server error while linking accounts."
      });
    }
  }
};

module.exports = partnerController;
