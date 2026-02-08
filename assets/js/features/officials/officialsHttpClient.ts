import httpClient from '../../shared/httpClient';
import { ApiOfficialListResponse } from '../../goChampsApiTypes';

const officialsUrl = (baseGoChampsApi: string, tournamentId: string) =>
  `${baseGoChampsApi}v1/officials?where[tournament_id]=${tournamentId}`;

export const fetchTournamentOfficials = async (
  baseGoChampsApi: string,
  tournamentId: string,
): Promise<ApiOfficialListResponse> => {
  return await httpClient.get<ApiOfficialListResponse>(
    officialsUrl(baseGoChampsApi, tournamentId),
  );
};

export default {
  fetchTournamentOfficials,
};
