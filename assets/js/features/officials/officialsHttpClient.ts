import httpClient from '../../shared/httpClient';
import {
  ApiOfficialListResponse,
  OfficialPinSignatureRequest,
  OfficialPinSignatureResponse,
} from '../../goChampsApiTypes';

const officialsUrl = (baseGoChampsApi: string, tournamentId: string) =>
  `${baseGoChampsApi}v1/officials?where[tournament_id]=${tournamentId}`;

const officialSignUrl = (baseGoChampsApi: string) =>
  `${baseGoChampsApi}v1/official-profiles/sign`;

export const fetchTournamentOfficials = async (
  baseGoChampsApi: string,
  tournamentId: string,
): Promise<ApiOfficialListResponse> => {
  return await httpClient.get<ApiOfficialListResponse>(
    officialsUrl(baseGoChampsApi, tournamentId),
  );
};

export const signOfficialWithPin = async (
  baseGoChampsApi: string,
  requestData: OfficialPinSignatureRequest,
): Promise<OfficialPinSignatureResponse> => {
  return await httpClient.post<
    OfficialPinSignatureRequest,
    OfficialPinSignatureResponse
  >(officialSignUrl(baseGoChampsApi), requestData);
};

export default {
  fetchTournamentOfficials,
  signOfficialWithPin,
};
