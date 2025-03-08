/*
 File: pregnancyRouter.js
 Purpose: Defines routes for pregnancy-tracker and swagger documentation.
 Created Date: 2025-02-08 CCS-8 Chamod Kamiss
 Author: Chamod Kamiss
 swagger doc: Melissa Joanne 

 last modified: 2025-02-08 | Chamod | CCS-8 Create routes for pregnancy tracker
*/

const express = require("express");
const PregnancyController = require("../controllers/pregnancyController");
const router = express.Router();

router.post("/", PregnancyController.createPregnancy);
router.get("/:userId", PregnancyController.getPregnancy);
router.put("/:userId", PregnancyController.updatePregnancy);
router.delete("/:userId", PregnancyController.deletePregnancy);

module.exports = router;
