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
  reportSlugs: string[],
): Promise<void> {
  const reportGenerators = {
    [REPORT_SLUGS.FIBA_SCORESHEET]: {
      generator: generatorAndUploaders.fibaScoresheet,
      displayName: 'FIBA Scoresheet',
    },
    [REPORT_SLUGS.FIBA_BOXSCORE]: {
      generator: generatorAndUploaders.fibaBoxScore,
      displayName: 'FIBA Box Score',
    },
  };

  try {
    callbacks.onProcessingStart();

    const completedAssets: Array<{ type: string; url: string }> = [];
    let hasError = false;

    const checkCompletion = () => {
      if (!hasError && completedAssets.length === reportSlugs.length) {
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

    const promises = reportSlugs.map((reportSlug) => {
      const config = reportGenerators[reportSlug];

      return config
        .generator({
          goChampsApiBaseUrl: apiBaseUrl,
          gameId,
          onSuccess: (fileReference: FileReference) => {
            completedAssets.push({
              type: reportSlug,
              url: fileReference.publicUrl,
            });
            callbacks.onReportComplete?.(reportSlug);
            checkCompletion();
          },
          onError: (error: Error) => {
            callbacks.onReportError?.(reportSlug, error.message);
            handleError(error, config.displayName);
          },
        })
        .catch((error: any) => {
          const message =
            error instanceof Error ? error.message : String(error);
          callbacks.onReportError?.(reportSlug, message);
          handleError(error, config.displayName);
        });
    });

    await Promise.allSettled(promises);
  } catch (error) {
    const message =
      error instanceof Error ? error.message : 'An unexpected error occurred';
    callbacks.onError(message);
  }
}
