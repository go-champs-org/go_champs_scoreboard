import httpClient from '../../shared/httpClient';
import { ApiResponse } from '../../types';

const getReportData = async <T>(
  gameId: string,
  reportSlug: string,
): Promise<T> => {
  const params = new URLSearchParams();
  params.append('report_slug', reportSlug);
  const url = `/scoreboard/report_data/${gameId}?${params.toString()}`;
  const response = await httpClient.get<ApiResponse<T>>(url);
  return response.data;
};

export default {
  getReportData,
};
