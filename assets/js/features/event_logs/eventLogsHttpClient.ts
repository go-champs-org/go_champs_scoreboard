import httpClient from '../../shared/httpClient';
import { ApiResponse, EventLog } from '../../types';

const getEventLogs = async (gameId: string): Promise<EventLog[]> => {
  const response = await httpClient.get<ApiResponse<EventLog[]>>(
    `/v1/games/${gameId}/event-logs`,
  );
  return response.data;
};

export default {
  getEventLogs,
};
