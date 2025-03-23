const express = require('express');
const router = express.Router();
const partnerController = require('../controllers/partnerController');

router.post('/link-partner', partnerController.linkPartner);

module.exports = router;