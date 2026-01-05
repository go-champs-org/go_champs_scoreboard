import { EVENT_KEYS } from '../../../constants';
import { FileReference } from '../../../features/upload/uploadHttpClient';
import { REPORT_SLUGS } from '../../../shared/reportRegistry';
import generatorAndUploaders from '../Reports/generatorAndUploaders';

export interface EndLiveCallbacks {
  pushEvent: (event: string, payload: any) => void;
  onCloseModal: () => void;
}

export interface ReportGenerationCallbacks extends EndLiveCallbacks {
  onProcessingStart: () => void;
  onProcessingComplete: () => void;
  onError: (error: string) => void;
  onReportComplete?: (reportId: string) => void;
  onReportError?: (reportId: string, error: string) => void;
}

export function executeBasicEndLive(callbacks: EndLiveCallbacks): void {
  callbacks.pushEvent(EVENT_KEYS.END_GAME_LIVE_MODE, {});
  callbacks.onCloseModal();
}

export async function executeMediumEndLive(
  gameId: string,
  apiBaseUrl: string,
  callbacks: ReportGenerationCallbacks,
): Promise<void> {
  try {
    callbacks.onProcessingStart();

    // Track completed assets
    const completedAssets: Array<{ type: string; url: string }> = [];
    let hasError = false;

    const checkCompletion = () => {
      if (!hasError && completedAssets.length === 2) {
        callbacks.onProcessingComplete();
        callbacks.pushEvent(EVENT_KEYS.END_GAME_LIVE_MODE, {
          assets: completedAssets,
        });
        callbacks.onCloseModal();
      }
    };

    const handleError = (error: any, reportType: string) => {
      if (!hasError) {
        hasError = true;
        const message = error instanceof Error ? error.message : String(error);
        callbacks.onError(`${reportType}: ${message}`);
      }
    };

    // Start both generators
    const scoresheetPromise = generatorAndUploaders
      .fibaScoresheet({
        goChampsApiBaseUrl: apiBaseUrl,
        gameId,
        onSuccess: (fileReference: FileReference) => {
          completedAssets.push({
            type: REPORT_SLUGS.FIBA_SCORESHEET,
            url: fileReference.publicUrl,
          });
          callbacks.onReportComplete?.(REPORT_SLUGS.FIBA_SCORESHEET);
          checkCompletion();
        },
        onError: (error: Error) => {
          callbacks.onReportError?.(
            REPORT_SLUGS.FIBA_SCORESHEET,
            error.message,
          );
          handleError(error, 'FIBA Scoresheet');
        },
      })
      .catch((error: any) => {
        callbacks.onReportError?.(
          REPORT_SLUGS.FIBA_SCORESHEET,
          error instanceof Error ? error.message : String(error),
        );
        handleError(error, 'FIBA Scoresheet');
      });

    const boxScorePromise = generatorAndUploaders
      .fibaBoxScore({
        goChampsApiBaseUrl: apiBaseUrl,
        gameId,
        onSuccess: (fileReference: FileReference) => {
          completedAssets.push({
            type: REPORT_SLUGS.FIBA_BOXSCORE,
            url: fileReference.publicUrl,
          });
          callbacks.onReportComplete?.(REPORT_SLUGS.FIBA_BOXSCORE);
          checkCompletion();
        },
        onError: (error: Error) => {
          callbacks.onReportError?.(REPORT_SLUGS.FIBA_BOXSCORE, error.message);
          handleError(error, 'FIBA Box Score');
        },
      })
      .catch((error: any) => {
        callbacks.onReportError?.(
          REPORT_SLUGS.FIBA_BOXSCORE,
          error instanceof Error ? error.message : String(error),
        );
        handleError(error, 'FIBA Box Score');
      });

    // Wait for both to complete or fail
    await Promise.allSettled([scoresheetPromise, boxScorePromise]);
  } catch (error) {
    const message =
      error instanceof Error ? error.message : 'An unexpected error occurred';
    callbacks.onError(message);
  }
}
