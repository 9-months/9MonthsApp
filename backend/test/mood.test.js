// moodController.test.js

const moodController = require('../controllers/moodController');
const moodService = require('../services/moodService');

// Mock the mood service
jest.mock('../services/moodService');

describe('MoodController', () => {
  let mockRequest;
  let mockResponse;
  
  beforeEach(() => {
    jest.clearAllMocks();
    
    // Setup mock request and response
    mockRequest = {
      body: {},
      params: {}
    };
    
    mockResponse = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
  });

  describe('createMoodEntry', () => {
    it('should create a mood entry and return 201 status', async () => {
      // Arrange
      const mockUserId = 'user123';
      const mockMoodData = { mood: 'happy', note: 'Great day!' };
      const mockCreatedEntry = { 
        _id: 'mood123', 
        userId: mockUserId, 
        ...mockMoodData, 
        date: new Date() 
      };
      
      mockRequest.params.userId = mockUserId;
      mockRequest.body = mockMoodData;
      
      moodService.createMoodEntry.mockResolvedValue(mockCreatedEntry);

      // Act
      await moodController.createMoodEntry(mockRequest, mockResponse);

      // Assert
      expect(moodService.createMoodEntry).toHaveBeenCalledWith(mockUserId, mockMoodData);
      expect(mockResponse.status).toHaveBeenCalledWith(201);
      expect(mockResponse.json).toHaveBeenCalledWith(mockCreatedEntry);
    });

    it('should return 500 status when service throws an error', async () => {
      // Arrange
      const mockUserId = 'user123';
      const mockMoodData = { mood: 'happy', note: 'Great day!' };
      const mockError = new Error('Service error');
      
      mockRequest.params.userId = mockUserId;
      mockRequest.body = mockMoodData;
      
      moodService.createMoodEntry.mockRejectedValue(mockError);

      // Act
      await moodController.createMoodEntry(mockRequest, mockResponse);

      // Assert
      expect(mockResponse.status).toHaveBeenCalledWith(500);
      expect(mockResponse.json).toHaveBeenCalledWith({ error: mockError.message });
    });
  });

  describe('getMoodEntries', () => {
    it('should get all mood entries and return 200 status', async () => {
      // Arrange
      const mockUserId = 'user123';
      const mockEntries = [
        { _id: 'mood1', userId: mockUserId, mood: 'happy', note: 'Great day!', date: new Date() },
        { _id: 'mood2', userId: mockUserId, mood: 'sad', note: 'Bad day', date: new Date() }
      ];
      
      mockRequest.params.userId = mockUserId;
      
      moodService.getMoodEntries.mockResolvedValue(mockEntries);

      // Act
      await moodController.getMoodEntries(mockRequest, mockResponse);

      // Assert
      expect(moodService.getMoodEntries).toHaveBeenCalledWith(mockUserId);
      expect(mockResponse.status).toHaveBeenCalledWith(200);
      expect(mockResponse.json).toHaveBeenCalledWith(mockEntries);
    });

    it('should return 500 status when service throws an error', async () => {
      // Arrange
      const mockUserId = 'user123';
      const mockError = new Error('Service error');
      
      mockRequest.params.userId = mockUserId;
      
      moodService.getMoodEntries.mockRejectedValue(mockError);

      // Act
      await moodController.getMoodEntries(mockRequest, mockResponse);

      // Assert
      expect(mockResponse.status).toHaveBeenCalledWith(500);
      expect(mockResponse.json).toHaveBeenCalledWith({ error: mockError.message });
    });
  });

  describe('getMoodEntry', () => {
    it('should get a specific mood entry and return 200 status', async () => {
      // Arrange
      const mockUserId = 'user123';
      const mockMoodId = 'mood123';
      const mockEntry = { 
        _id: mockMoodId, 
        userId: mockUserId, 
        mood: 'happy', 
        note: 'Great day!', 
        date: new Date() 
      };
      
      mockRequest.params.userId = mockUserId;
      mockRequest.params.moodId = mockMoodId;
      
      moodService.getMoodEntry.mockResolvedValue(mockEntry);

      // Act
      await moodController.getMoodEntry(mockRequest, mockResponse);

      // Assert
      expect(moodService.getMoodEntry).toHaveBeenCalledWith(mockUserId, mockMoodId);
      expect(mockResponse.status).toHaveBeenCalledWith(200);
      expect(mockResponse.json).toHaveBeenCalledWith(mockEntry);
    });

    it('should return 404 status when entry is not found', async () => {
      // Arrange
      const mockUserId = 'user123';
      const mockMoodId = 'mood123';
      
      mockRequest.params.userId = mockUserId;
      mockRequest.params.moodId = mockMoodId;
      
      moodService.getMoodEntry.mockResolvedValue(null);

      // Act
      await moodController.getMoodEntry(mockRequest, mockResponse);

      // Assert
      expect(mockResponse.status).toHaveBeenCalledWith(404);
      expect(mockResponse.json).toHaveBeenCalledWith({ error: 'Mood entry not found' });
    });

    it('should return 500 status when service throws an error', async () => {
      // Arrange
      const mockUserId = 'user123';
      const mockMoodId = 'mood123';
      const mockError = new Error('Service error');
      
      mockRequest.params.userId = mockUserId;
      mockRequest.params.moodId = mockMoodId;
      
      moodService.getMoodEntry.mockRejectedValue(mockError);

      // Act
      await moodController.getMoodEntry(mockRequest, mockResponse);

      // Assert
      expect(mockResponse.status).toHaveBeenCalledWith(500);
      expect(mockResponse.json).toHaveBeenCalledWith({ error: mockError.message });
    });
  });

  describe('updateMoodEntry', () => {
    it('should update a mood entry and return 200 status', async () => {
      // Arrange
      const mockUserId = 'user123';
      const mockMoodId = 'mood123';
      const mockMoodData = { mood: 'excited', note: 'Updated note!' };
      const mockUpdatedEntry = { 
        _id: mockMoodId, 
        userId: mockUserId, 
        ...mockMoodData, 
        date: new Date() 
      };
      
      mockRequest.params.userId = mockUserId;
      mockRequest.params.moodId = mockMoodId;
      mockRequest.body = mockMoodData;
      
      moodService.updateMoodEntry.mockResolvedValue(mockUpdatedEntry);

      // Act
      await moodController.updateMoodEntry(mockRequest, mockResponse);

      // Assert
      expect(moodService.updateMoodEntry).toHaveBeenCalledWith(
        mockUserId, 
        mockMoodId, 
        mockMoodData
      );
      expect(mockResponse.status).toHaveBeenCalledWith(200);
      expect(mockResponse.json).toHaveBeenCalledWith(mockUpdatedEntry);
    });

    it('should return 404 status when entry is not found', async () => {
      // Arrange
      const mockUserId = 'user123';
      const mockMoodId = 'mood123';
      const mockMoodData = { mood: 'excited', note: 'Updated note!' };
      
      mockRequest.params.userId = mockUserId;
      mockRequest.params.moodId = mockMoodId;
      mockRequest.body = mockMoodData;
      
      moodService.updateMoodEntry.mockResolvedValue(null);

      // Act
      await moodController.updateMoodEntry(mockRequest, mockResponse);

      // Assert
      expect(mockResponse.status).toHaveBeenCalledWith(404);
      expect(mockResponse.json).toHaveBeenCalledWith({ error: 'Mood entry not found' });
    });

    it('should return 500 status when service throws an error', async () => {
      // Arrange
      const mockUserId = 'user123';
      const mockMoodId = 'mood123';
      const mockMoodData = { mood: 'excited', note: 'Updated note!' };
      const mockError = new Error('Service error');
      
      mockRequest.params.userId = mockUserId;
      mockRequest.params.moodId = mockMoodId;
      mockRequest.body = mockMoodData;
      
      moodService.updateMoodEntry.mockRejectedValue(mockError);

      // Act
      await moodController.updateMoodEntry(mockRequest, mockResponse);

      // Assert
      expect(mockResponse.status).toHaveBeenCalledWith(500);
      expect(mockResponse.json).toHaveBeenCalledWith({ error: mockError.message });
    });
  });

  describe('deleteMoodEntry', () => {
    it('should delete a mood entry and return 200 status', async () => {
      // Arrange
      const mockUserId = 'user123';
      const mockMoodId = 'mood123';
      const mockDeletedEntry = { 
        _id: mockMoodId, 
        userId: mockUserId, 
        mood: 'happy', 
        note: 'Great day!', 
        date: new Date() 
      };
      
      mockRequest.params.userId = mockUserId;
      mockRequest.params.moodId = mockMoodId;
      
      moodService.deleteMoodEntry.mockResolvedValue(mockDeletedEntry);

      // Act
      await moodController.deleteMoodEntry(mockRequest, mockResponse);

      // Assert
      expect(moodService.deleteMoodEntry).toHaveBeenCalledWith(mockUserId, mockMoodId);
      expect(mockResponse.status).toHaveBeenCalledWith(200);
      expect(mockResponse.json).toHaveBeenCalledWith({ message: 'Mood entry successfully deleted' });
    });

    it('should return 404 status when entry is not found', async () => {
      // Arrange
      const mockUserId = 'user123';
      const mockMoodId = 'mood123';
      
      mockRequest.params.userId = mockUserId;
      mockRequest.params.moodId = mockMoodId;
      
      moodService.deleteMoodEntry.mockResolvedValue(null);

      // Act
      await moodController.deleteMoodEntry(mockRequest, mockResponse);

      // Assert
      expect(mockResponse.status).toHaveBeenCalledWith(404);
      expect(mockResponse.json).toHaveBeenCalledWith({ error: 'Mood entry not found' });
    });

    it('should return 500 status when service throws an error', async () => {
      // Arrange
      const mockUserId = 'user123';
      const mockMoodId = 'mood123';
      const mockError = new Error('Service error');
      
      mockRequest.params.userId = mockUserId;
      mockRequest.params.moodId = mockMoodId;
      
      moodService.deleteMoodEntry.mockRejectedValue(mockError);

      // Act
      await moodController.deleteMoodEntry(mockRequest, mockResponse);

      // Assert
      expect(mockResponse.status).toHaveBeenCalledWith(500);
      expect(mockResponse.json).toHaveBeenCalledWith({ error: mockError.message });
    });
  });
});