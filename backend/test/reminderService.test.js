const mongoose = require('mongoose');
const Reminder = require('../models/Reminder');
const reminderService = require('../services/reminderService');

jest.mock('../models/Reminder');

describe('ReminderService', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('createReminder', () => {
    it('should create a new reminder', async () => {
      const mockReminderData = { title: 'Test Reminder', dateTime: '2025-12-01T10:00:00Z', timezone: 'UTC', type: 'other' };
      const mockReminder = { ...mockReminderData, save: jest.fn().mockResolvedValue(mockReminderData) };
      Reminder.mockImplementation(() => mockReminder);

      const result = await reminderService.createReminder('user123', mockReminderData);

      expect(Reminder).toHaveBeenCalledWith({ userId: 'user123', ...mockReminderData });
      expect(mockReminder.save).toHaveBeenCalled();
      expect(result).toEqual(mockReminderData);
    });

    it('should throw an error if creation fails', async () => {
      const mockReminderData = { title: 'Test Reminder', dateTime: '2025-12-01T10:00:00Z', timezone: 'UTC', type: 'other' };
      const mockReminder = { ...mockReminderData, save: jest.fn().mockRejectedValue(new Error('Save failed')) };
      Reminder.mockImplementation(() => mockReminder);

      await expect(reminderService.createReminder('user123', mockReminderData)).rejects.toThrow('Error creating reminder: Save failed');
    });
  });

  describe('getRemindersByUser', () => {
    it('should fetch reminders for a user', async () => {
      const mockReminders = [{ title: 'Reminder 1' }, { title: 'Reminder 2' }];
      Reminder.find = jest.fn().mockReturnValue({ sort: jest.fn().mockResolvedValue(mockReminders) });

      const result = await reminderService.getRemindersByUser('user123');

      expect(Reminder.find).toHaveBeenCalledWith({ userId: 'user123' });
      expect(result).toEqual(mockReminders);
    });

    it('should throw an error if fetching fails', async () => {
      Reminder.find = jest.fn().mockReturnValue({ sort: jest.fn().mockRejectedValue(new Error('Fetch failed')) });

      await expect(reminderService.getRemindersByUser('user123')).rejects.toThrow('Error fetching reminders: Fetch failed');
    });
  });

  describe('getReminder', () => {
    it('should fetch a specific reminder', async () => {
      const mockReminder = { title: 'Reminder 1' };
      Reminder.findOne = jest.fn().mockResolvedValue(mockReminder);

      const result = await reminderService.getReminder('user123', 'reminder123');

      expect(Reminder.findOne).toHaveBeenCalledWith({ _id: 'reminder123', userId: 'user123' });
      expect(result).toEqual(mockReminder);
    });

    it('should throw an error if fetching fails', async () => {
      Reminder.findOne = jest.fn().mockRejectedValue(new Error('Fetch failed'));

      await expect(reminderService.getReminder('user123', 'reminder123')).rejects.toThrow('Error fetching reminder: Fetch failed');
    });
  });

  describe('updateReminder', () => {
    it('should update a specific reminder', async () => {
      const mockUpdatedReminder = { title: 'Updated Reminder' };
      Reminder.findOneAndUpdate = jest.fn().mockResolvedValue(mockUpdatedReminder);

      const result = await reminderService.updateReminder('user123', 'reminder123', { title: 'Updated Reminder' });

      expect(Reminder.findOneAndUpdate).toHaveBeenCalledWith(
        { _id: 'reminder123', userId: 'user123' },
        { title: 'Updated Reminder' },
        { new: true }
      );
      expect(result).toEqual(mockUpdatedReminder);
    });

    it('should throw an error if updating fails', async () => {
      Reminder.findOneAndUpdate = jest.fn().mockRejectedValue(new Error('Update failed'));

      await expect(reminderService.updateReminder('user123', 'reminder123', { title: 'Updated Reminder' })).rejects.toThrow('Error updating reminder: Update failed');
    });
  });

  describe('deleteReminder', () => {
    it('should delete a specific reminder', async () => {
      Reminder.findOneAndDelete = jest.fn().mockResolvedValue({});

      const result = await reminderService.deleteReminder('user123', 'reminder123');

      expect(Reminder.findOneAndDelete).toHaveBeenCalledWith({ _id: 'reminder123', userId: 'user123' });
      expect(result).toEqual({});
    });

    it('should throw an error if deletion fails', async () => {
      Reminder.findOneAndDelete = jest.fn().mockRejectedValue(new Error('Delete failed'));

      await expect(reminderService.deleteReminder('user123', 'reminder123')).rejects.toThrow('Error deleting reminder: Delete failed');
    });
  });

  describe('getRemindersForNotification', () => {
    it('should fetch reminders within a time window', async () => {
      const mockReminders = [{ title: 'Reminder 1' }];
      Reminder.find = jest.fn().mockResolvedValue(mockReminders);

      const result = await reminderService.getRemindersForNotification('2025-12-01T00:00:00Z', '2025-12-01T23:59:59Z');

      expect(Reminder.find).toHaveBeenCalledWith({
        dateTime: { $gte: '2025-12-01T00:00:00Z', $lte: '2025-12-01T23:59:59Z' },
        isCompleted: false,
      });
      expect(result).toEqual(mockReminders);
    });

    it('should throw an error if fetching fails', async () => {
      Reminder.find = jest.fn().mockRejectedValue(new Error('Fetch failed'));

      await expect(reminderService.getRemindersForNotification('2025-12-01T00:00:00Z', '2025-12-01T23:59:59Z')).rejects.toThrow('Error fetching reminders for notifications: Fetch failed');
    });
  });
});
