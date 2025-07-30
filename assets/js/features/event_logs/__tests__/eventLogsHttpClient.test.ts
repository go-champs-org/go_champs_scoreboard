/**
 * @jest-environment jsdom
 */

import eventLogsHttpClient from '../eventLogsHttpClient';

// Mock fetch globally since httpClient uses fetch
const mockFetch = jest.fn();
global.fetch = mockFetch;

describe('eventLogsHttpClient', () => {
  const gameId = 'test-game-123';

  beforeEach(() => {
    mockFetch.mockClear();
    // Clear console.log mocks
    jest.spyOn(console, 'log').mockImplementation();
    jest.spyOn(console, 'error').mockImplementation();
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe('getEventLogs', () => {
    it('fetches event logs without filters', async () => {
      // Arrange
      const mockEventLogs = [
        { id: '1', type: 'start-game', timestamp: '2023-01-01T00:00:00Z' },
        { id: '2', type: 'score', timestamp: '2023-01-01T00:01:00Z' },
      ];
      const expectedUrl = `/v1/games/${gameId}/event-logs`;

      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ data: mockEventLogs }),
      });

      // Act
      const result = await eventLogsHttpClient.getEventLogs(gameId);

      // Assert
      expect(mockFetch).toHaveBeenCalledWith(
        expectedUrl,
        expect.objectContaining({
          headers: expect.objectContaining({
            'Content-Type': 'application/json',
          }),
        }),
      );
      expect(result).toEqual(mockEventLogs);
    });

    it('fetches event logs with filters', async () => {
      // Arrange
      const mockEventLogs = [
        { id: '1', type: 'score', timestamp: '2023-01-01T00:00:00Z' },
      ];
      const filters = { type: 'score', limit: '10' };
      const expectedUrl = `/v1/games/${gameId}/event-logs?type=score&limit=10`;

      // Reset and setup mock for this specific test
      mockFetch.mockClear();
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ data: mockEventLogs }),
      });

      // Act
      const result = await eventLogsHttpClient.getEventLogs(gameId, filters);

      // Assert
      expect(mockFetch).toHaveBeenCalledTimes(1);
      expect(mockFetch).toHaveBeenCalledWith(
        expectedUrl,
        expect.objectContaining({
          headers: expect.objectContaining({
            'Content-Type': 'application/json',
          }),
        }),
      );
      expect(result).toEqual(mockEventLogs);
    });
  });

  describe('deleteLastEvent', () => {
    it('deletes the last event successfully', async () => {
      // Arrange
      const expectedUrl = `/v1/games/${gameId}/event-logs/last`;
      mockFetch.mockResolvedValueOnce({
        ok: true,
        url: expectedUrl,
      });

      // Act
      await eventLogsHttpClient.deleteLastEvent(gameId);

      // Assert
      expect(mockFetch).toHaveBeenCalledWith(
        expectedUrl,
        expect.objectContaining({
          method: 'DELETE',
        }),
      );
    });

    it('handles API errors when deleting last event', async () => {
      // Arrange
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 404,
        statusText: 'Not Found',
      });

      // Act & Assert
      await expect(
        eventLogsHttpClient.deleteLastEvent(gameId),
      ).rejects.toThrow();
      expect(mockFetch).toHaveBeenCalledWith(
        `/v1/games/${gameId}/event-logs/last`,
        expect.objectContaining({
          method: 'DELETE',
        }),
      );
    });

    it('constructs the correct URL with the provided game ID', async () => {
      // Arrange
      const customGameId = 'custom-game-456';
      const expectedUrl = `/v1/games/${customGameId}/event-logs/last`;
      mockFetch.mockResolvedValueOnce({
        ok: true,
        url: expectedUrl,
      });

      // Act
      await eventLogsHttpClient.deleteLastEvent(customGameId);

      // Assert
      expect(mockFetch).toHaveBeenCalledWith(
        expectedUrl,
        expect.objectContaining({
          method: 'DELETE',
        }),
      );
    });
  });
});
