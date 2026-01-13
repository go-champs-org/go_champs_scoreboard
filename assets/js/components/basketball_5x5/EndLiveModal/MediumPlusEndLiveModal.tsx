import React from 'react';
import Modal from '../../Modal';
import { useTranslation } from 'react-i18next';
import { GameState } from '../../../types';
import { useConfig } from '../../../shared/Config';
import { shouldShowEarlyEndWarning } from './timeValidation';
import {
  executeMediumEndLive,
  ReportGenerationCallbacks,
} from './endLiveFlows';
import { useProcessingState } from './useProcessingState';
import { PROCESSING_STATES, REPORT_STATUSES } from './processingState';
import { REPORT_SLUGS } from '../../../shared/reportRegistry';
import {
  ReportsList,
  ProcessingMessage,
  ErrorDisplay,
  ModalFooter,
} from './EndLiveModalComponents';

// Main Component
interface MediumPlusEndLiveModalProps {
  game_state: GameState;
  showModal: boolean;
  onCloseModal: () => void;
  pushEvent: (event: string, payload: any) => void;
}

// Generate both reports for MediumPlus view
const MEDIUM_PLUS_REPORTS = [
  REPORT_SLUGS.FIBA_SCORESHEET,
  REPORT_SLUGS.FIBA_BOXSCORE,
];

function MediumPlusEndLiveModal({
  game_state,
  showModal,
  onCloseModal,
  pushEvent,
}: MediumPlusEndLiveModalProps) {
  const { t } = useTranslation();
  const config = useConfig();
  const {
    processingManager,
    startProcessing,
    completeProcessing,
    setError,
    updateReportState,
    retry,
  } = useProcessingState(PROCESSING_STATES.IDLE, MEDIUM_PLUS_REPORTS);

  const shouldShowWarning = shouldShowEarlyEndWarning(
    game_state.live_state.started_at,
  );

  const handleEndLive = async () => {
    const callbacks: ReportGenerationCallbacks = {
      pushEvent,
      onCloseModal,
      onProcessingStart: () => {
        startProcessing();
        // Mark all reports as generating
        MEDIUM_PLUS_REPORTS.forEach((reportSlug) => {
          updateReportState(reportSlug, REPORT_STATUSES.GENERATING);
        });
      },
      onProcessingComplete: () => {
        completeProcessing();
      },
      onError: (error: string) => {
        setError(error);
      },
      onReportComplete: (reportId: string) => {
        updateReportState(reportId, REPORT_STATUSES.COMPLETED);
      },
      onReportError: (reportId: string, error: string) => {
        updateReportState(reportId, REPORT_STATUSES.ERROR, error);
      },
    };

    await executeMediumEndLive(
      game_state.id,
      config.getApiHost(),
      callbacks,
      MEDIUM_PLUS_REPORTS,
    );
  };

  const handleRetry = () => {
    retry();
  };

  return (
    <Modal
      title={t('basketball.modals.endLiveConfirmation.title')}
      onClose={processingManager.isProcessing ? () => {} : onCloseModal}
      showModal={showModal}
    >
      <div className="end-live-modal">
        {shouldShowWarning && (
          <div className="warning">
            <p>{t('basketball.modals.endLiveConfirmation.endSoonWarning')}</p>
          </div>
        )}

        <div className="content">
          <p>{t('basketball.modals.endLiveConfirmation.messageWithReports')}</p>

          <ReportsList reports={processingManager.reports} />

          {processingManager.isProcessing && <ProcessingMessage />}

          {processingManager.state === PROCESSING_STATES.ERROR &&
            processingManager.error && (
              <ErrorDisplay error={processingManager.error} />
            )}
        </div>

        <ModalFooter
          processingManager={processingManager}
          onCloseModal={onCloseModal}
          onEndLive={handleEndLive}
          onRetry={handleRetry}
        />
      </div>
    </Modal>
  );
}

export default MediumPlusEndLiveModal;
