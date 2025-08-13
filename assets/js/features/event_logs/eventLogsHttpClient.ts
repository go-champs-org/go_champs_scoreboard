import httpClient from '../../shared/httpClient';
import { ApiResponse, EventLog } from '../../types';

const getEventLogs = async (
  gameId: string,
  filters?: Record<string, string>,
): Promise<EventLog[]> => {
  const params = new URLSearchParams();
  if (filters) {
    Object.entries(filters).forEach(([key, value]) => {
      params.append(key, value);
    });
  }
  const url = params.toString()
    ? `/v1/games/${gameId}/event-logs?${params.toString()}`
    : `/v1/games/${gameId}/event-logs`;

  const response = await httpClient.get<ApiResponse<EventLog[]>>(url);
  return response.data;
};

const deleteLastEvent = async (gameId: string): Promise<void> => {
  const url = `/v1/games/${gameId}/event-logs/last`;
  await httpClient.delete(url);
};

const deleteEvent = async (eventId: string): Promise<void> => {
  const url = `/v1/event-logs/${eventId}`;
  await httpClient.delete(url);
};

export default {
  getEventLogs,
  deleteLastEvent,
  deleteEvent,
};
