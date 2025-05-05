import httpClient from '../../shared/httpClient';
import { ApiResponse, EventLog } from '../../types';

const getEventLogs = async (
  gameId: string,
  filters?: Record<string, string>,
): Promise<EventLog[]> => {
  const params = new URLSearchParams(filters);
  const url = params.size
    ? `/v1/games/${gameId}/event-logs?${params.toString()}`
    : `/v1/games/${gameId}/event-logs`;

  console.log('Fetching event logs from URL:', url);
  const response = await httpClient.get<ApiResponse<EventLog[]>>(url);
  return response.data;
};

export default {
  getEventLogs,
};
