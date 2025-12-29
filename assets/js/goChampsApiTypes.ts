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
