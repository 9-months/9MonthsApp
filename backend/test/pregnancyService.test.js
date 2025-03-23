const PregnancyService = require('../services/pregnancyService');
const Pregnancy = require('../models/Pregnancy');
const WeeklyData = require('../models/WeeklyData');

// Mock the Mongoose models
jest.mock('../models/Pregnancy');
jest.mock('../models/WeeklyData');

describe('PregnancyService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('calculateWeek', () => {
    test('should calculate correct week based on due date', () => {
      // Mock the current date
      const mockDate = new Date('2025-05-01');
      const realDate = Date;
      global.Date = class extends Date {
        constructor() {
          return mockDate;
        }
      };

      // Due date 280 days (40 weeks) from now
      const dueDate = new Date('2026-02-05');
      const week = PregnancyService.calculateWeek(dueDate);
      
      // Reset Date
      global.Date = realDate;
      
      expect(week).toBeLessThanOrEqual(40);
      expect(week).toBeGreaterThanOrEqual(1);
    });

    test('should return 40 if calculated week is greater than 40', () => {
      // Mock the current date
      const mockDate = new Date('2026-03-01');
      const realDate = Date;
      global.Date = class extends Date {
        constructor() {
          return mockDate;
        }
      };

      // Due date in the past
      const dueDate = new Date('2026-02-05');
      const week = PregnancyService.calculateWeek(dueDate);
      
      // Reset Date
      global.Date = realDate;
      
      expect(week).toBe(40);
    });

  });

  describe('getWeeklyData', () => {
    test('should return weekly data for valid week', async () => {
      const mockWeeklyData = {
        week: 10,
        babySize: 'Strawberry',
        tips: ['Eat healthy', 'Exercise regularly'],
        babyDevelopment: 'Developing organs',
        motherChanges: 'Morning sickness may subside',
        toObject: jest.fn().mockReturnValue({
          week: 10,
          babySize: 'Strawberry',
          tips: ['Eat healthy', 'Exercise regularly'],
          babyDevelopment: 'Developing organs',
          motherChanges: 'Morning sickness may subside'
        })
      };

      WeeklyData.findOne.mockResolvedValue(mockWeeklyData);

      const result = await PregnancyService.getWeeklyData(10);
      expect(WeeklyData.findOne).toHaveBeenCalledWith({ week: 10 });
      expect(result).toEqual(mockWeeklyData);
    });

    test('should return default data when weekly data not found', async () => {
      WeeklyData.findOne.mockResolvedValue(null);

      const result = await PregnancyService.getWeeklyData(5);
      expect(WeeklyData.findOne).toHaveBeenCalledWith({ week: 5 });
      expect(result.week).toBe(5);
      expect(result.babySize).toBe('Information not available');
      expect(result.tips).toEqual(['Stay hydrated', 'Get regular checkups']);
      expect(result.toObject()).toEqual(result);
    });
  });

  describe('createPregnancy', () => {
    test('should create a new pregnancy record', async () => {
      const userData = {
        userId: 'user123',
        dueDate: '2026-02-05'
      };

      const mockSavedPregnancy = {
        userId: 'user123',
        dueDate: new Date('2026-02-05'),
        toObject: jest.fn().mockReturnValue({
          userId: 'user123',
          dueDate: new Date('2026-02-05')
        })
      };

      const mockWeeklyData = {
        week: 10,
        babySize: 'Strawberry',
        tips: ['Eat healthy'],
        babyDevelopment: 'Developing organs',
        motherChanges: 'Morning sickness may subside',
        toObject: jest.fn().mockReturnValue({
          week: 10,
          babySize: 'Strawberry',
          tips: ['Eat healthy'],
          babyDevelopment: 'Developing organs',
          motherChanges: 'Morning sickness may subside'
        })
      };

      // Mock the Pregnancy constructor and save method
      Pregnancy.mockImplementation(() => ({
        save: jest.fn().mockResolvedValue(mockSavedPregnancy)
      }));

      // Mock the calculateWeek method
      const calculateWeekSpy = jest.spyOn(PregnancyService, 'calculateWeek');
      calculateWeekSpy.mockReturnValue(10);

      // Mock the getWeeklyData method
      const getWeeklyDataSpy = jest.spyOn(PregnancyService, 'getWeeklyData');
      getWeeklyDataSpy.mockResolvedValue(mockWeeklyData);

      const result = await PregnancyService.createPregnancy(userData);

      expect(Pregnancy).toHaveBeenCalledWith({
        userId: 'user123',
        dueDate: expect.any(Date)
      });
      expect(calculateWeekSpy).toHaveBeenCalledWith(mockSavedPregnancy.dueDate);
      expect(getWeeklyDataSpy).toHaveBeenCalledWith(10);
      expect(result).toEqual({
        userId: 'user123',
        dueDate: new Date('2026-02-05'),
        currentWeek: 10,
        week: 10,
        babySize: 'Strawberry',
        tips: ['Eat healthy'],
        babyDevelopment: 'Developing organs',
        motherChanges: 'Morning sickness may subside'
      });

      calculateWeekSpy.mockRestore();
      getWeeklyDataSpy.mockRestore();
    });

    test('should throw error when pregnancy creation fails', async () => {
      const userData = {
        userId: 'user123',
        dueDate: '2026-02-05'
      };

      const mockError = new Error('Database error');

      // Mock the Pregnancy constructor and save method to throw error
      Pregnancy.mockImplementation(() => ({
        save: jest.fn().mockRejectedValue(mockError)
      }));

      await expect(PregnancyService.createPregnancy(userData)).rejects.toThrow('Database error');
    });
  });

  describe('getPregnancyByUserId', () => {
    test('should return pregnancy data for valid user ID', async () => {
      const mockPregnancy = {
        userId: 'user123',
        dueDate: new Date('2026-02-05'),
        toObject: jest.fn().mockReturnValue({
          userId: 'user123',
          dueDate: new Date('2026-02-05')
        })
      };

      const mockWeeklyData = {
        week: 10,
        babySize: 'Strawberry',
        tips: ['Eat healthy'],
        babyDevelopment: 'Developing organs',
        motherChanges: 'Morning sickness may subside',
        toObject: jest.fn().mockReturnValue({
          week: 10,
          babySize: 'Strawberry',
          tips: ['Eat healthy'],
          babyDevelopment: 'Developing organs',
          motherChanges: 'Morning sickness may subside'
        })
      };

      Pregnancy.findOne.mockResolvedValue(mockPregnancy);

      // Mock the calculateWeek method
      const calculateWeekSpy = jest.spyOn(PregnancyService, 'calculateWeek');
      calculateWeekSpy.mockReturnValue(10);

      // Mock the getWeeklyData method
      const getWeeklyDataSpy = jest.spyOn(PregnancyService, 'getWeeklyData');
      getWeeklyDataSpy.mockResolvedValue(mockWeeklyData);

      const result = await PregnancyService.getPregnancyByUserId('user123');

      expect(Pregnancy.findOne).toHaveBeenCalledWith({ userId: 'user123' });
      expect(calculateWeekSpy).toHaveBeenCalledWith(mockPregnancy.dueDate);
      expect(getWeeklyDataSpy).toHaveBeenCalledWith(10);
      expect(result).toEqual({
        userId: 'user123',
        dueDate: new Date('2026-02-05'),
        currentWeek: 10,
        week: 10,
        babySize: 'Strawberry',
        tips: ['Eat healthy'],
        babyDevelopment: 'Developing organs',
        motherChanges: 'Morning sickness may subside'
      });

      calculateWeekSpy.mockRestore();
      getWeeklyDataSpy.mockRestore();
    });

    test('should throw error when pregnancy data not found', async () => {
      Pregnancy.findOne.mockResolvedValue(null);

      await expect(PregnancyService.getPregnancyByUserId('nonexistent')).rejects.toThrow('Pregnancy data not found');
    });
  });

  describe('updatePregnancy', () => {
    test('should update pregnancy data for valid user ID', async () => {
      const updatedData = {
        dueDate: '2026-03-10'
      };

      const mockUpdatedPregnancy = {
        userId: 'user123',
        dueDate: new Date('2026-03-10'),
        toObject: jest.fn().mockReturnValue({
          userId: 'user123',
          dueDate: new Date('2026-03-10')
        })
      };

      const mockWeeklyData = {
        week: 8,
        babySize: 'Grape',
        tips: ['Rest well'],
        babyDevelopment: 'Growing fingers',
        motherChanges: 'Increased appetite',
        toObject: jest.fn().mockReturnValue({
          week: 8,
          babySize: 'Grape',
          tips: ['Rest well'],
          babyDevelopment: 'Growing fingers',
          motherChanges: 'Increased appetite'
        })
      };

      Pregnancy.findOneAndUpdate.mockResolvedValue(mockUpdatedPregnancy);

      // Mock the calculateWeek method
      const calculateWeekSpy = jest.spyOn(PregnancyService, 'calculateWeek');
      calculateWeekSpy.mockReturnValue(8);

      // Mock the getWeeklyData method
      const getWeeklyDataSpy = jest.spyOn(PregnancyService, 'getWeeklyData');
      getWeeklyDataSpy.mockResolvedValue(mockWeeklyData);

      const result = await PregnancyService.updatePregnancy('user123', updatedData);

      expect(Pregnancy.findOneAndUpdate).toHaveBeenCalledWith(
        { userId: 'user123' },
        { $set: { dueDate: updatedData.dueDate } },
        { new: true }
      );
      expect(calculateWeekSpy).toHaveBeenCalledWith(mockUpdatedPregnancy.dueDate);
      expect(getWeeklyDataSpy).toHaveBeenCalledWith(8);
      expect(result).toEqual({
        userId: 'user123',
        dueDate: new Date('2026-03-10'),
        currentWeek: 8,
        week: 8,
        babySize: 'Grape',
        tips: ['Rest well'],
        babyDevelopment: 'Growing fingers',
        motherChanges: 'Increased appetite'
      });

      calculateWeekSpy.mockRestore();
      getWeeklyDataSpy.mockRestore();
    });

    test('should throw error when pregnancy data not found for update', async () => {
      Pregnancy.findOneAndUpdate.mockResolvedValue(null);

      await expect(PregnancyService.updatePregnancy('nonexistent', { dueDate: '2026-03-10' })).rejects.toThrow('Pregnancy data not found');
    });
  });

  describe('deletePregnancy', () => {
    test('should delete pregnancy data for valid user ID', async () => {
      Pregnancy.deleteOne.mockResolvedValue({ deletedCount: 1 });

      const result = await PregnancyService.deletePregnancy('user123');

      expect(Pregnancy.deleteOne).toHaveBeenCalledWith({ userId: 'user123' });
      expect(result).toEqual({ message: 'Pregnancy data deleted successfully' });
    });

    test('should throw error when pregnancy data not found for deletion', async () => {
      Pregnancy.deleteOne.mockResolvedValue({ deletedCount: 0 });

      await expect(PregnancyService.deletePregnancy('nonexistent')).rejects.toThrow('Pregnancy data not found');
    });
  });
});
