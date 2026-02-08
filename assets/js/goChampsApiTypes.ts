export type ApiUploadFileType =
  | 'athlete-profiles-photos'
  | 'game-assets'
  | 'player-photos'
  | 'registration-consents'
  | 'team-logos'
  | 'organization-logos';

export interface ApiUploadPostRequest {
  filename: string;
  content_type: string;
  size: number;
  file_type: ApiUploadFileType;
}

export interface ApiUploadFile {
  filename: string;
  url: string;
  public_url: string;
}

export interface ApiUploadPostResponse {
  data: ApiUploadFile;
}

export interface ApiOfficial {
  id: string;
  name: string;
  license_number: string | null;
  tournament_id: string;
  username: string | null;
}

export interface ApiOfficialListResponse {
  data: ApiOfficial[];
}

export interface ApiRegistrationResponseResponse {
  email: string | null;
  name: string | null;
  shirt_name: string | null;
  shirt_number: string | null;
}

export interface ApiPlayerRegistrationResponse {
  id: string;
  response: ApiRegistrationResponseResponse;
}

export interface ApiPlayer {
  id: string;
  name: string;
  shirt_number: string | null;
  shirt_name: string | null;
  license_number: string | null;
  state: string;
  team_id: string;
  facebook: string | null;
  instagram: string | null;
  twitter: string | null;
  username: string | null;
  photo_url: string | null;
  registration_response: ApiPlayerRegistrationResponse | null;
  status: string | null;
}

export interface ApiCoach {
  id: string;
  name: string;
  type: string;
}

export interface ApiTeam {
  id: string;
  name: string;
  players: ApiPlayer[];
  coaches: ApiCoach[];
  logo_url: string | null;
  primary_color: string | null;
  tri_code: string | null;
}

export interface ApiTeamResponse {
  data: ApiTeam;
}
