const PregnancyController = require('../controllers/pregnancyController');
const PregnancyService = require('../services/pregnancyService');

// Mock the PregnancyService
jest.mock('../services/pregnancyService');

describe('PregnancyController', () => {
  let req, res;

  beforeEach(() => {
    req = {
      body: {},
      params: {}
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    jest.clearAllMocks();
  });

  describe('createPregnancy', () => {
    test('should create pregnancy and return 201 status', async () => {
      req.body = {
        userId: 'user123',
        dueDate: '2026-02-05'
      };

      const mockPregnancyData = {
        userId: 'user123',
        dueDate: new Date('2026-02-05'),
        currentWeek: 10,
        babySize: 'Strawberry',
        tips: ['Eat healthy'],
        babyDevelopment: 'Developing organs',
        motherChanges: 'Morning sickness may subside'
      };

      PregnancyService.createPregnancy.mockResolvedValue(mockPregnancyData);

      await PregnancyController.createPregnancy(req, res);

      expect(PregnancyService.createPregnancy).toHaveBeenCalledWith(req.body);
      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(mockPregnancyData);
    });

    test('should handle errors and return 400 status', async () => {
      req.body = {
        userId: 'user123',
        // Missing dueDate
      };

      const mockError = new Error('Invalid data');
      PregnancyService.createPregnancy.mockRejectedValue(mockError);

      await PregnancyController.createPregnancy(req, res);

      expect(PregnancyService.createPregnancy).toHaveBeenCalledWith(req.body);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Invalid data' });
    });
  });

  describe('getPregnancy', () => {
    test('should get pregnancy data and return 200 status', async () => {
      req.params.userId = 'user123';

      const mockPregnancyData = {
        userId: 'user123',
        dueDate: new Date('2026-02-05'),
        currentWeek: 10,
        babySize: 'Strawberry',
        tips: ['Eat healthy'],
        babyDevelopment: 'Developing organs',
        motherChanges: 'Morning sickness may subside'
      };

      PregnancyService.getPregnancyByUserId.mockResolvedValue(mockPregnancyData);

      await PregnancyController.getPregnancy(req, res);

      expect(PregnancyService.getPregnancyByUserId).toHaveBeenCalledWith('user123');
      expect(res.json).toHaveBeenCalledWith(mockPregnancyData);
    });

    test('should handle not found error and return 404 status', async () => {
      req.params.userId = 'nonexistent';

      const mockError = new Error('Pregnancy data not found');
      PregnancyService.getPregnancyByUserId.mockRejectedValue(mockError);

      await PregnancyController.getPregnancy(req, res);

      expect(PregnancyService.getPregnancyByUserId).toHaveBeenCalledWith('nonexistent');
      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({ message: 'Pregnancy data not found' });
    });

    test('should handle other errors and return 500 status', async () => {
      req.params.userId = 'user123';

      const mockError = new Error('Database error');
      PregnancyService.getPregnancyByUserId.mockRejectedValue(mockError);

      await PregnancyController.getPregnancy(req, res);

      expect(PregnancyService.getPregnancyByUserId).toHaveBeenCalledWith('user123');
      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({ error: 'Database error' });
    });
  });

  describe('updatePregnancy', () => {
    test('should update pregnancy data and return 200 status', async () => {
      req.params.userId = 'user123';
      req.body = {
        dueDate: '2026-03-10'
      };

      const mockUpdatedPregnancy = {
        userId: 'user123',
        dueDate: new Date('2026-03-10'),
        currentWeek: 8,
        babySize: 'Grape',
        tips: ['Rest well'],
        babyDevelopment: 'Growing fingers',
        motherChanges: 'Increased appetite'
      };

      PregnancyService.updatePregnancy.mockResolvedValue(mockUpdatedPregnancy);

      await PregnancyController.updatePregnancy(req, res);

      expect(PregnancyService.updatePregnancy).toHaveBeenCalledWith('user123', req.body);
      expect(res.json).toHaveBeenCalledWith(mockUpdatedPregnancy);
    });

    test('should handle not found error and return 404 status', async () => {
      req.params.userId = 'nonexistent';
      req.body = {
        dueDate: '2026-03-10'
      };

      const mockError = new Error('Pregnancy data not found');
      PregnancyService.updatePregnancy.mockRejectedValue(mockError);

      await PregnancyController.updatePregnancy(req, res);

      expect(PregnancyService.updatePregnancy).toHaveBeenCalledWith('nonexistent', req.body);
      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({ message: 'Pregnancy data not found' });
    });

    test('should handle other errors and return 500 status', async () => {
      req.params.userId = 'user123';
      req.body = {
        dueDate: '2026-03-10'
      };

      const mockError = new Error('Database error');
      PregnancyService.updatePregnancy.mockRejectedValue(mockError);

      await PregnancyController.updatePregnancy(req, res);

      expect(PregnancyService.updatePregnancy).toHaveBeenCalledWith('user123', req.body);
      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({ error: 'Database error' });
    });
  });

  describe('deletePregnancy', () => {
    test('should delete pregnancy data and return 200 status', async () => {
      req.params.userId = 'user123';

      const mockResult = { message: 'Pregnancy data deleted successfully' };
      PregnancyService.deletePregnancy.mockResolvedValue(mockResult);

      await PregnancyController.deletePregnancy(req, res);

      expect(PregnancyService.deletePregnancy).toHaveBeenCalledWith('user123');
      expect(res.json).toHaveBeenCalledWith(mockResult);
    });

    test('should handle not found error and return 404 status', async () => {
      req.params.userId = 'nonexistent';

      const mockError = new Error('Pregnancy data not found');
      PregnancyService.deletePregnancy.mockRejectedValue(mockError);

      await PregnancyController.deletePregnancy(req, res);

      expect(PregnancyService.deletePregnancy).toHaveBeenCalledWith('nonexistent');
      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({ message: 'Pregnancy data not found' });
    });

    test('should handle other errors and return 500 status', async () => {
      req.params.userId = 'user123';

      const mockError = new Error('Database error');
      PregnancyService.deletePregnancy.mockRejectedValue(mockError);

      await PregnancyController.deletePregnancy(req, res);

      expect(PregnancyService.deletePregnancy).toHaveBeenCalledWith('user123');
      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({ error: 'Database error' });
    });
  });
});