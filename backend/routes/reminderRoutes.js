const express = require('express');
const reminderController = require('../controllers/reminderController');

const router = express.Router();

router.post('/create', reminderController.createReminder);
router.get('/get/user/:userId', reminderController.getRemindersByUser);
router.put('/update/:id', reminderController.updateReminder);
router.delete('/delete/:id', reminderController.deleteReminder);

module.exports = router;
