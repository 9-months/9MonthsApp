const express = require('express');
const router = express.Router();
const reminderController = require('../controllers/reminderController');

router.post('/:userId', reminderController.createReminder);
router.get('/:userId', reminderController.getRemindersByUser);
router.get('/:userId/:reminderId', reminderController.getReminder);
router.put('/:userId/:reminderId', reminderController.updateReminder);
router.delete('/:userId/:reminderId', reminderController.deleteReminder);

module.exports = router;