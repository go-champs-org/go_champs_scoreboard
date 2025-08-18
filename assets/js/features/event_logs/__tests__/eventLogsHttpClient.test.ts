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

  describe('deleteEvent', () => {
    it('deletes a specific event successfully', async () => {
      // Arrange
      const eventId = 'event-123';
      const expectedUrl = `/v1/event-logs/${eventId}`;
      mockFetch.mockResolvedValueOnce({
        ok: true,
        url: expectedUrl,
      });

      // Act
      await eventLogsHttpClient.deleteEvent(eventId);

      // Assert
      expect(mockFetch).toHaveBeenCalledWith(
        expectedUrl,
        expect.objectContaining({
          method: 'DELETE',
        }),
      );
    });

    it('handles API errors when deleting a specific event', async () => {
      // Arrange
      const eventId = 'event-123';
      const expectedUrl = `/v1/event-logs/${eventId}`;
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 404,
        statusText: 'Not Found',
        url: expectedUrl,
      });

      // Act
      await eventLogsHttpClient.deleteEvent(eventId);

      // Assert
      expect(mockFetch).toHaveBeenCalledWith(
        `/v1/event-logs/${eventId}`,
        expect.objectContaining({
          method: 'DELETE',
        }),
      );
      expect(consoleErrorSpy).toHaveBeenCalledWith(
        'Error deleting resource:',
        404,
        'Not Found',
      );
    });

    it('constructs the correct URL with the provided event ID', async () => {
      // Arrange
      const customEventId = 'custom-event-456';
      const expectedUrl = `/v1/event-logs/${customEventId}`;
      mockFetch.mockResolvedValueOnce({
        ok: true,
        url: expectedUrl,
      });

      // Act
      await eventLogsHttpClient.deleteEvent(customEventId);

      // Assert
      expect(mockFetch).toHaveBeenCalledWith(
        expectedUrl,
        expect.objectContaining({
          method: 'DELETE',
        }),
      );
    });

    it('handles network errors when deleting a specific event', async () => {
      // Arrange
      const eventId = 'event-123';
      const networkError = new Error('Network Error');
      mockFetch.mockRejectedValueOnce(networkError);

      // Act & Assert
      await expect(eventLogsHttpClient.deleteEvent(eventId)).rejects.toThrow(
        'Network Error',
      );
      expect(mockFetch).toHaveBeenCalledWith(
        `/v1/event-logs/${eventId}`,
        expect.objectContaining({
          method: 'DELETE',
        }),
      );
    });

    it('calls the delete endpoint exactly once', async () => {
      // Arrange
      const eventId = 'event-789';
      const expectedUrl = `/v1/event-logs/${eventId}`;
      mockFetch.mockResolvedValueOnce({
        ok: true,
        url: expectedUrl,
      });

      // Act
      await eventLogsHttpClient.deleteEvent(eventId);

      // Assert
      expect(mockFetch).toHaveBeenCalledTimes(1);
    });
  });

  describe('postEventLogs', () => {
    it('posts event log successfully', async () => {
      // Arrange
      const mockEventLog = {
        key: 'update-player-stat',
        payload: {
          player_id: 'player-123',
          stat_type: 'points',
          value: 2,
          operation: 'increment',
        },
        game_id: 'game-456',
        game_clock_time: 720,
        game_clock_period: 1,
      };
      const expectedUrl = '/v1/event-logs';

      mockFetch.mockResolvedValueOnce({
        ok: true,
        url: expectedUrl,
        text: async () => JSON.stringify({ success: true }),
      });

      // Act
      await eventLogsHttpClient.postEventLogs(mockEventLog);

      // Assert
      expect(mockFetch).toHaveBeenCalledWith(
        expectedUrl,
        expect.objectContaining({
          method: 'POST',
          headers: expect.objectContaining({
            'Content-Type': 'application/json',
          }),
          body: JSON.stringify(mockEventLog),
        }),
      );
    });

    it('posts event log without payload successfully', async () => {
      // Arrange
      const mockEventLog = {
        key: 'start-game',
        game_id: 'game-789',
        game_clock_time: 0,
        game_clock_period: 1,
      };
      const expectedUrl = '/v1/event-logs';

      mockFetch.mockResolvedValueOnce({
        ok: true,
        url: expectedUrl,
        text: async () => JSON.stringify({ success: true }),
      });

      // Act
      await eventLogsHttpClient.postEventLogs(mockEventLog);

      // Assert
      expect(mockFetch).toHaveBeenCalledWith(
        expectedUrl,
        expect.objectContaining({
          method: 'POST',
          headers: expect.objectContaining({
            'Content-Type': 'application/json',
          }),
          body: JSON.stringify(mockEventLog),
        }),
      );
    });

    it('handles API errors when posting event log', async () => {
      // Arrange
      const mockEventLog = {
        key: 'update-team-stat',
        payload: { team_id: 'team-123', stat_type: 'score', value: 3 },
        game_id: 'game-456',
        game_clock_time: 360,
        game_clock_period: 2,
      };
      const expectedUrl = '/v1/event-logs';
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();

      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 400,
        statusText: 'Bad Request',
        url: expectedUrl,
        text: async () => JSON.stringify({ error: 'Bad Request' }),
      });

      // Act
      await eventLogsHttpClient.postEventLogs(mockEventLog);

      // Assert
      expect(mockFetch).toHaveBeenCalledWith(
        expectedUrl,
        expect.objectContaining({
          method: 'POST',
          body: JSON.stringify(mockEventLog),
        }),
      );
      expect(consoleErrorSpy).toHaveBeenCalledWith(
        'Error posting resource:',
        400,
        'Bad Request',
      );
    });

    it('handles network errors when posting event log', async () => {
      // Arrange
      const mockEventLog = {
        key: 'update-coach-stat',
        payload: {
          coach_id: 'coach-123',
          stat_type: 'timeouts_called',
          value: 1,
        },
        game_id: 'game-456',
        game_clock_time: 180,
        game_clock_period: 1,
      };
      const networkError = new Error('Network Error');
      mockFetch.mockRejectedValueOnce(networkError);

      // Act & Assert
      await expect(
        eventLogsHttpClient.postEventLogs(mockEventLog),
      ).rejects.toThrow('Network Error');
      expect(mockFetch).toHaveBeenCalledWith(
        '/v1/event-logs',
        expect.objectContaining({
          method: 'POST',
          body: JSON.stringify(mockEventLog),
        }),
      );
    });

    it('calls the post endpoint exactly once', async () => {
      // Arrange
      const mockEventLog = {
        key: 'end-period',
        game_id: 'game-999',
        game_clock_time: 0,
        game_clock_period: 1,
      };
      const expectedUrl = '/v1/event-logs';

      mockFetch.mockResolvedValueOnce({
        ok: true,
        url: expectedUrl,
        text: async () => JSON.stringify({ success: true }),
      });

      // Act
      await eventLogsHttpClient.postEventLogs(mockEventLog);

      // Assert
      expect(mockFetch).toHaveBeenCalledTimes(1);
    });

    it('sends the correct request body', async () => {
      // Arrange
      const mockEventLog = {
        key: 'substitute-player',
        payload: {
          player_in_id: 'player-in-456',
          player_out_id: 'player-out-789',
          team_id: 'team-123',
        },
        game_id: 'game-456',
        game_clock_time: 540,
        game_clock_period: 2,
      };
      const expectedUrl = '/v1/event-logs';

      mockFetch.mockResolvedValueOnce({
        ok: true,
        url: expectedUrl,
        text: async () => JSON.stringify({ success: true }),
      });

      // Act
      await eventLogsHttpClient.postEventLogs(mockEventLog);

      // Assert
      expect(mockFetch).toHaveBeenCalledWith(
        expectedUrl,
        expect.objectContaining({
          method: 'POST',
          headers: expect.objectContaining({
            'Content-Type': 'application/json',
          }),
          body: JSON.stringify(mockEventLog),
        }),
      );
    });
  });
});
