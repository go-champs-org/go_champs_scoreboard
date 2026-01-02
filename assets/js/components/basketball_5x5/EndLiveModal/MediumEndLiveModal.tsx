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
import {
  PROCESSING_STATES,
  REPORT_STATUSES,
  ReportItem as ReportItemType,
  ProcessingStateManager,
} from './processingState';
import { REPORT_SLUGS } from '../../../shared/reportRegistry';

// Sub-components
interface ReportStatusIconProps {
  status: string;
}

function ReportStatusIcon({ status }: ReportStatusIconProps) {
  if (status === REPORT_STATUSES.GENERATING) {
    return <div className="spinner has-text-info"></div>;
  }
  if (status === REPORT_STATUSES.COMPLETED) {
    return <span className="has-text-success">✓</span>;
  }
  if (status === REPORT_STATUSES.ERROR) {
    return <span className="has-text-danger">✗</span>;
  }
  if (status === REPORT_STATUSES.PENDING) {
    return <span className="has-text-grey-light">⏳</span>;
  }
  return null;
}

interface ReportItemProps {
  report: ReportItemType;
}

function ReportItem({ report }: ReportItemProps) {
  const { t } = useTranslation();

  const getStatusTextClass = (status: string) => {
    if (status === REPORT_STATUSES.COMPLETED) return 'has-text-success';
    if (status === REPORT_STATUSES.ERROR) return 'has-text-danger';
    if (status === REPORT_STATUSES.GENERATING) return 'has-text-white';
    return 'has-text-grey';
  };

  return (
    <li className="is-flex is-align-items-center mb-2">
      <span className="icon is-small mr-2">
        <ReportStatusIcon status={report.status} />
      </span>
      <span className={getStatusTextClass(report.status)}>
        {t(report.translationKey)}
      </span>
      {report.status === REPORT_STATUSES.ERROR && report.error && (
        <span className="has-text-danger is-size-7 ml-2">- {report.error}</span>
      )}
    </li>
  );
}

interface ReportsListProps {
  reports: ReportItemType[];
}

function ReportsList({ reports }: ReportsListProps) {
  const { t } = useTranslation();

  return (
    <div className="reports-list mt-4">
      <p className="has-text-grey is-size-7 mb-2">
        {t('basketball.modals.endLiveConfirmation.reportGenerationInfo')}
      </p>
      <ul className="is-size-7">
        {reports.map((report) => (
          <ReportItem key={report.id} report={report} />
        ))}
      </ul>
    </div>
  );
}

function ProcessingMessage() {
  const { t } = useTranslation();

  return (
    <div className="processing-message mt-3">
      <p className="has-text-grey is-size-7">
        {t('basketball.modals.endLiveConfirmation.cannotClose')}
      </p>
    </div>
  );
}

interface ErrorDisplayProps {
  error: string;
}

function ErrorDisplay({ error }: ErrorDisplayProps) {
  const { t } = useTranslation();

  return (
    <div className="error-state mt-4">
      <div className="notification is-danger is-light">
        <p className="has-text-weight-semibold">
          {t('basketball.modals.endLiveConfirmation.errorTitle')}
        </p>
        <p className="is-size-7">{error}</p>
      </div>
    </div>
  );
}

interface ModalFooterProps {
  processingManager: ProcessingStateManager;
  onCloseModal: () => void;
  onEndLive: () => void;
  onRetry: () => void;
}

function ModalFooter({
  processingManager,
  onCloseModal,
  onEndLive,
  onRetry,
}: ModalFooterProps) {
  const { t } = useTranslation();

  if (processingManager.state === PROCESSING_STATES.ERROR) {
    return (
      <div className="footer mt-4 is-flex is-justify-content-flex-end">
        <button className="button is-small" onClick={onCloseModal}>
          {t('basketball.modals.endLiveConfirmation.cancel')}
        </button>
        <button className="button is-warning is-small" onClick={onRetry}>
          {t('basketball.modals.endLiveConfirmation.retry')}
        </button>
      </div>
    );
  }

  return (
    <div className="footer mt-4 is-flex is-justify-content-flex-end">
      <button
        className="button is-small"
        onClick={onCloseModal}
        disabled={processingManager.isProcessing}
      >
        {t('basketball.modals.endLiveConfirmation.cancel')}
      </button>
      <button
        className={`button is-danger is-small ${
          processingManager.isProcessing ? 'is-loading' : ''
        }`}
        onClick={onEndLive}
        disabled={processingManager.isProcessing}
      >
        {processingManager.isProcessing
          ? t('basketball.modals.endLiveConfirmation.processing')
          : t('basketball.modals.endLiveConfirmation.endLive')}
      </button>
    </div>
  );
}

// Main Component
interface MediumEndLiveModalProps {
  game_state: GameState;
  showModal: boolean;
  onCloseModal: () => void;
  pushEvent: (event: string, payload: any) => void;
}

function MediumEndLiveModal({
  game_state,
  showModal,
  onCloseModal,
  pushEvent,
}: MediumEndLiveModalProps) {
  const { t } = useTranslation();
  const config = useConfig();
  const {
    processingManager,
    startProcessing,
    completeProcessing,
    setError,
    updateReportState,
    retry,
  } = useProcessingState(PROCESSING_STATES.IDLE);

  const shouldShowWarning = shouldShowEarlyEndWarning(
    game_state.live_state.started_at,
  );

  const handleEndLive = async () => {
    const callbacks: ReportGenerationCallbacks = {
      pushEvent,
      onCloseModal,
      onProcessingStart: () => {
        startProcessing();
        updateReportState(
          REPORT_SLUGS.FIBA_SCORESHEET,
          REPORT_STATUSES.GENERATING,
        );
      },
      onProcessingComplete: () => {
        updateReportState(
          REPORT_SLUGS.FIBA_SCORESHEET,
          REPORT_STATUSES.COMPLETED,
        );
        completeProcessing();
      },
      onError: (error: string) => {
        updateReportState(
          REPORT_SLUGS.FIBA_SCORESHEET,
          REPORT_STATUSES.ERROR,
          error,
        );
        setError(error);
      },
    };

    await executeMediumEndLive(game_state.id, config.getApiHost(), callbacks);
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

export default MediumEndLiveModal;
