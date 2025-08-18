import httpClient from '../../shared/httpClient';
import { ApiResponse, EventLog, PostEventLog } from '../../types';

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

const deleteEvent = async (eventId: string): Promise<void> => {
  const url = `/v1/event-logs/${eventId}`;
  await httpClient.delete(url);
};

const postEventLogs = async (eventLog: PostEventLog): Promise<void> => {
  const url = `/v1/event-logs`;
  await httpClient.post(url, eventLog);
};

export default {
  getEventLogs,
  deleteEvent,
  postEventLogs,
};
