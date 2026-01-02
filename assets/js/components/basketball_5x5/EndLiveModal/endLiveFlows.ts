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

    const onSuccess = (fileReference: FileReference) => {
      callbacks.onProcessingComplete();
      callbacks.pushEvent(EVENT_KEYS.END_GAME_LIVE_MODE, {
        assets: [
          {
            type: REPORT_SLUGS.FIBA_SCORESHEET,
            url: fileReference.publicUrl,
          },
        ],
      });
      callbacks.onCloseModal();
    };

    const onError = (error: Error) => {
      callbacks.onError(error.message);
    };

    await generatorAndUploaders.fibaScoresheet({
      goChampsApiBaseUrl: apiBaseUrl,
      gameId,
      onSuccess,
      onError,
    });
  } catch (error) {
    const message =
      error instanceof Error ? error.message : 'An unexpected error occurred';
    callbacks.onError(message);
  }
}
