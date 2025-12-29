import httpClient from '../../shared/httpClient';
import {
  ApiUploadPostRequest,
  ApiUploadPostResponse,
} from '../../goChampsApiTypes';

const uploadUrl = (baseGoChampsApi: string) => `${baseGoChampsApi}v1/upload`;

export interface FileReference {
  filename: string;
  publicUrl: string;
  url: string;
}

interface File extends Document {
  type: string;
}

interface UploadFile {
  baseGoChampsApi: string;
  file: Blob;
  fileReference: ApiUploadPostRequest;
  setProgress: (progress: number) => void;
  onSucess: (fileReference: FileReference) => void;
  onError: () => void;
}

const postUploadPresignedUrl = async (
  baseGoChampsApi: string,
  uploadRequest: ApiUploadPostRequest,
) =>
  await httpClient.post<ApiUploadPostRequest, ApiUploadPostResponse>(
    `${uploadUrl(baseGoChampsApi)}/presigned-url`,
    uploadRequest,
  );

const singAndUpload = async ({
  baseGoChampsApi,
  file,
  fileReference,
  setProgress,
  onSucess,
  onError,
}: UploadFile) => {
  // 1. Get presigned URL from Elixir backend
  const {
    data: { filename, url, public_url: publicUrl },
  } = await postUploadPresignedUrl(baseGoChampsApi, fileReference);

  // 2. Upload directly to Cloudflare R2 using XMLHttpRequest to track progress
  const xhr = new XMLHttpRequest();
  xhr.open('PUT', url, true);
  xhr.setRequestHeader('Content-Type', file.type);

  xhr.upload.onprogress = (event) => {
    if (event.lengthComputable) {
      const percentComplete = Math.round((event.loaded * 100) / event.total);
      setProgress(percentComplete);
    }
  };

  xhr.onload = () => {
    if (xhr.status === 200) {
      const cleanUrl = new URL(url);
      cleanUrl.search = '';
      onSucess({ filename, url: cleanUrl.toString(), publicUrl });
    } else {
      onError();
    }
  };

  xhr.onerror = () => {
    onError();
  };

  xhr.send(file);
};

export default {
  singAndUpload,
};
