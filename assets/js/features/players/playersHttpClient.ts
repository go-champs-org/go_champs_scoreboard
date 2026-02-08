import httpClient from '../../shared/httpClient';
import { ApiTeamResponse } from '../../goChampsApiTypes';

const teamUrl = (baseGoChampsApi: string, teamId: string) =>
  `${baseGoChampsApi}v1/teams/${teamId}`;

export const fetchTeamPlayers = async (
  baseGoChampsApi: string,
  teamId: string,
): Promise<ApiTeamResponse> => {
  return await httpClient.get<ApiTeamResponse>(
    teamUrl(baseGoChampsApi, teamId),
  );
};

export default {
  fetchTeamPlayers,
};
