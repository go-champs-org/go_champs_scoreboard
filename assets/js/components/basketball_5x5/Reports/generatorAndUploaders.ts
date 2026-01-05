import { generate } from '../../../features/reports/pdfGenerator';
import uploadHttpClient, {
  FileReference,
} from '../../../features/upload/uploadHttpClient';
import { REPORT_SLUGS } from '../../../shared/reportRegistry';

const fibaBoxScore = async ({
  goChampsApiBaseUrl,
  gameId,
  onProgress,
  onSuccess,
  onError,
}: {
  goChampsApiBaseUrl: string;
  gameId: string;
  onProgress?: (progress: number) => void;
  onSuccess?: (fileReference: any) => void;
  onError?: (error: any) => void;
}) => {
  try {
    const reportFile = await generate(REPORT_SLUGS.FIBA_BOXSCORE, gameId);
    const filename = `${REPORT_SLUGS.FIBA_BOXSCORE}.pdf`;

    await uploadHttpClient.singAndUpload({
      baseGoChampsApi: goChampsApiBaseUrl,
      file: reportFile,
      fileReference: {
        filename,
        file_type: 'game-assets',
        content_type: 'application/pdf',
        size: reportFile.size,
      },
      setProgress:
        onProgress ||
        ((progress: number) => {
          console.log(`Upload progress: ${progress}%`);
        }),
      onSucess:
        onSuccess ||
        ((fileReference: FileReference) => {
          console.log('File uploaded successfully:', fileReference);
        }),
      onError:
        onError ||
        ((error: any) => {
          console.error('Error uploading file', error);
        }),
    });
  } catch (err) {
    if (onError) onError(err);
    else console.error('Error generating or uploading FIBA boxscore', err);
  }
};

const fibaScoresheet = async ({
  goChampsApiBaseUrl,
  gameId,
  onProgress,
  onSuccess,
  onError,
}: {
  goChampsApiBaseUrl: string;
  gameId: string;
  onProgress?: (progress: number) => void;
  onSuccess?: (fileReference: any) => void;
  onError?: (error: any) => void;
}) => {
  try {
    const reportFile = await generate(REPORT_SLUGS.FIBA_SCORESHEET, gameId);
    const filename = `${REPORT_SLUGS.FIBA_SCORESHEET}.pdf`;

    await uploadHttpClient.singAndUpload({
      baseGoChampsApi: goChampsApiBaseUrl,
      file: reportFile,
      fileReference: {
        filename,
        file_type: 'game-assets',
        content_type: 'application/pdf',
        size: reportFile.size,
      },
      setProgress:
        onProgress ||
        ((progress: number) => {
          console.log(`Upload progress: ${progress}%`);
        }),
      onSucess:
        onSuccess ||
        ((fileReference: FileReference) => {
          console.log('File uploaded successfully:', fileReference);
        }),
      onError:
        onError ||
        ((error: any) => {
          console.error('Error uploading file', error);
        }),
    });
  } catch (err) {
    if (onError) onError(err);
    else console.error('Error generating or uploading FIBA scoresheet', err);
  }
};

export default {
  fibaBoxScore,
  fibaScoresheet,
};
