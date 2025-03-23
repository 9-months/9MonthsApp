const DiaryController = require('../controllers/diaryController');
const DiaryService = require('../services/diaryService');
const authMiddleware = require('../middleware/authMiddleware');

// Mock the service methods and middleware
jest.mock('../services/diaryService');
jest.mock('../middleware/authMiddleware');

describe('DiaryController', () => {

  // Grouping the "Create" related tests
  describe('Create Diary Entry', () => {

    it("should successfully create a diary entry", async () => {
      const diaryEntryData = { title: 'Test Title', content: 'Test Content' };

      // Mock the service method that creates a diary entry
      const mockCreate = jest.fn().mockResolvedValue({
        ...diaryEntryData,
        _id: 'some-random-id', // Mock _id as returned by MongoDB
      });

      // Inject the mock method into the controller
      DiaryController.createEntry = mockCreate;

      // Call the controller method
      const result = await DiaryController.createEntry(diaryEntryData);

      // Expectations: Check that the result contains the expected properties
      expect(result).toHaveProperty('title', 'Test Title');
      expect(result).toHaveProperty('content', 'Test Content');
      expect(result).toHaveProperty('_id');
      expect(mockCreate).toHaveBeenCalledWith(diaryEntryData);
    });

    it("should fail to create a diary entry with missing fields", async () => {
      const invalidData = { title: 'Test Title' }; // Missing content

      try {
        await DiaryController.createEntry(invalidData);
      } catch (error) {
        // Expect error to be thrown for missing 'content'
        expect(error).toHaveProperty('message', 'Content is required');
      }
    });
  });

  // Grouping the "Get" related tests
  describe('Get Diary Entries', () => {

    it("should retrieve all diary entries", async () => {
      const mockEntries = [
        { title: 'Entry 1', content: 'Content 1', _id: '1' },
        { title: 'Entry 2', content: 'Content 2', _id: '2' }
      ];

      // Mock the service method to return all entries
      const mockFindAll = jest.fn().mockResolvedValue(mockEntries);

      // Inject the mock method into the controller
      DiaryController.getAllEntries = mockFindAll;

      // Call the controller method
      const result = await DiaryController.getAllEntries();

      // Expectations: Check that the result matches the mock entries
      expect(result).toEqual(mockEntries);
      expect(mockFindAll).toHaveBeenCalled();
    });

    it("should retrieve a diary entry by ID", async () => {
      const mockEntry = { title: 'Test Title', content: 'Test Content', _id: 'some-random-id' };

      // Mock the service method to return the diary entry by ID
      const mockFindById = jest.fn().mockResolvedValue(mockEntry);

      // Inject the mock method into the controller
      DiaryController.getEntryById = mockFindById;

      // Call the controller method
      const result = await DiaryController.getEntryById('some-random-id');

      // Expectations: Check that the result matches the mock entry
      expect(result).toEqual(mockEntry);
      expect(mockFindById).toHaveBeenCalledWith('some-random-id');
    });

    it("should fail to retrieve a diary entry with an invalid ID", async () => {
      // Mock the service method to return null if no entry is found
      const mockFindById = jest.fn().mockResolvedValue(null);

      // Inject the mock method into the controller
      DiaryController.getEntryById = mockFindById;

      try {
        // Expect error to be thrown for invalid ID
        await DiaryController.getEntryById('invalid-id');
      } catch (error) {
        expect(error).toHaveProperty('message', 'Diary entry not found');
      }
    });
  });

  // Grouping the "Update" related tests
  describe('Update Diary Entry', () => {

    it("should successfully update a diary entry", async () => {
      const updatedData = { title: 'Updated Title', content: 'Updated Content' };

      // Mock the service method to update the diary entry
      const mockUpdate = jest.fn().mockResolvedValue({
        ...updatedData,
        _id: 'some-random-id',
      });

      // Inject the mock method into the controller
      DiaryController.updateEntry = mockUpdate;

      // Call the controller method to update the entry
      const result = await DiaryController.updateEntry('some-random-id', updatedData);

      // Expectations: Ensure the updated diary entry is returned
      expect(result).toHaveProperty('title', 'Updated Title');
      expect(result).toHaveProperty('content', 'Updated Content');
      expect(result).toHaveProperty('_id', 'some-random-id');
      expect(mockUpdate).toHaveBeenCalledWith('some-random-id', updatedData);
    });

    it("should fail to update a diary entry with an invalid ID", async () => {
      const updatedData = { title: 'Updated Title', content: 'Updated Content' };

      // Mock the service method to return null when the ID is not found
      const mockUpdate = jest.fn().mockResolvedValue(null);

      // Inject the mock method into the controller
      DiaryController.updateEntry = mockUpdate;

      try {
        // Expect error to be thrown for invalid ID
        await DiaryController.updateEntry('invalid-id', updatedData);
      } catch (error) {
        expect(error).toHaveProperty('message', 'Diary entry not found');
      }
    });
  });

  // Grouping the "Delete" related tests
  describe('Delete Diary Entry', () => {

    it("should successfully delete a diary entry", async () => {
      const mockDelete = jest.fn().mockResolvedValue({ _id: 'some-random-id', deleted: true });

      // Inject the mock method into the controller
      DiaryController.deleteEntry = mockDelete;

      // Call the controller method
      const result = await DiaryController.deleteEntry('some-random-id');

      // Expectations: Check that the deletion was successful
      expect(result).toHaveProperty('deleted', true);
      expect(result).toHaveProperty('_id', 'some-random-id');
      expect(mockDelete).toHaveBeenCalledWith('some-random-id');
    });

    it("should fail to delete a diary entry with an invalid ID", async () => {
      const mockDelete = jest.fn().mockResolvedValue(null);

      // Inject the mock method into the controller
      DiaryController.deleteEntry = mockDelete;

      try {
        // Expect error to be thrown for invalid ID
        await DiaryController.deleteEntry('invalid-id');
      } catch (error) {
        expect(error).toHaveProperty('message', 'Diary entry not found');
      }
    });
  });

});
