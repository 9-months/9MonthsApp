/*
 File: pregnancyController.js
 Purpose: Handles Handles HTTP requests.
 Created Date: 2025-02-08 CCS-8 Chamod Kamiss
 Author: Chamod Kamiss

 last modified: 2025-02-08 | Chamod | CCS-9 Create Controllers
*/

const PregnancyService = require("../services/pregnancyService");

class PregnancyController {
  async createPregnancy(req, res) {
    try {
      console.log('Received create pregnancy request:', {
        body: req.body,
        headers: req.headers
      });
      
      const pregnancy = await PregnancyService.createPregnancy(req.body);
      console.log('Created pregnancy:', pregnancy);
      
      res.status(201).json(pregnancy);
    } catch (error) {
      console.error('Create pregnancy error:', error);
      res.status(500).json({ error: error.message });
    }
  }

  async getPregnancy(req, res) {
    try {
      const pregnancy = await PregnancyService.getPregnancyByUserId(
        req.params.userId
      );
      res.json(pregnancy);
    } catch (error) {
      if (error.message === "Pregnancy data not found") {
        res.status(404).json({ message: error.message });
      } else {
        res.status(500).json({ error: error.message });
      }
    }
  }

  // Update pregnancy record
  async updatePregnancy(req, res) {
    try {
      const pregnancy = await PregnancyService.updatePregnancy(
        req.params.userId,
        req.body
      );
      res.json(pregnancy);
    } catch (error) {
      if (error.message === "Pregnancy data not found") {
        res.status(404).json({ message: error.message });
      } else {
        res.status(500).json({ error: error.message });
      }
    }
  }

  // Delete pregnancy record
  async deletePregnancy(req, res) {
    try {
      const result = await PregnancyService.deletePregnancy(req.params.userId);
      res.json(result);
    } catch (error) {
      if (error.message === "Pregnancy data not found") {
        res.status(404).json({ message: error.message });
      } else {
        res.status(500).json({ error: error.message });
      }
    }
  }
}

module.exports = new PregnancyController();
