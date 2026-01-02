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
  } = useProcessingState('idle');

  const shouldShowWarning = shouldShowEarlyEndWarning(
    game_state.live_state.started_at,
  );

  const handleEndLive = async () => {
    const callbacks: ReportGenerationCallbacks = {
      pushEvent,
      onCloseModal,
      onProcessingStart: () => {
        startProcessing();
        updateReportState('fiba-scoresheet', 'generating');
      },
      onProcessingComplete: () => {
        updateReportState('fiba-scoresheet', 'completed');
        completeProcessing();
      },
      onError: (error: string) => {
        updateReportState('fiba-scoresheet', 'error', error);
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

          <div className="reports-list mt-4">
            <p className="has-text-grey is-size-7 mb-2">
              {t('basketball.modals.endLiveConfirmation.reportGenerationInfo')}
            </p>
            <ul className="is-size-7">
              {processingManager.reports.map((report) => (
                <li
                  key={report.id}
                  className="is-flex is-align-items-center mb-2"
                >
                  <span className="icon is-small mr-2">
                    {report.status === 'generating' && (
                      <div className="spinner has-text-info"></div>
                    )}
                    {report.status === 'completed' && (
                      <span className="has-text-success">✓</span>
                    )}
                    {report.status === 'error' && (
                      <span className="has-text-danger">✗</span>
                    )}
                    {report.status === 'pending' && (
                      <span className="has-text-grey-light">⏳</span>
                    )}
                  </span>
                  <span
                    className={`${
                      report.status === 'completed'
                        ? 'has-text-success'
                        : report.status === 'error'
                        ? 'has-text-danger'
                        : report.status === 'generating'
                        ? 'has-text-white'
                        : 'has-text-grey'
                    }`}
                  >
                    {t(report.translationKey)}
                  </span>
                  {report.status === 'error' && report.error && (
                    <span className="has-text-danger is-size-7 ml-2">
                      - {report.error}
                    </span>
                  )}
                </li>
              ))}
            </ul>
          </div>

          {processingManager.isProcessing && (
            <div className="processing-message mt-3">
              <p className="has-text-grey is-size-7">
                {t('basketball.modals.endLiveConfirmation.cannotClose')}
              </p>
            </div>
          )}

          {processingManager.state === 'error' && processingManager.error && (
            <div className="error-state mt-4">
              <div className="notification is-danger is-light">
                <p className="has-text-weight-semibold">
                  {t('basketball.modals.endLiveConfirmation.errorTitle')}
                </p>
                <p className="is-size-7">{processingManager.error}</p>
              </div>
            </div>
          )}
        </div>

        <div className="footer mt-4 is-flex is-justify-content-flex-end">
          {processingManager.state === 'error' ? (
            <>
              <button className="button is-small" onClick={onCloseModal}>
                {t('basketball.modals.endLiveConfirmation.cancel')}
              </button>
              <button
                className="button is-warning is-small"
                onClick={handleRetry}
              >
                {t('basketball.modals.endLiveConfirmation.retry')}
              </button>
            </>
          ) : (
            <>
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
                onClick={handleEndLive}
                disabled={processingManager.isProcessing}
              >
                {processingManager.isProcessing
                  ? t('basketball.modals.endLiveConfirmation.processing')
                  : t('basketball.modals.endLiveConfirmation.endLive')}
              </button>
            </>
          )}
        </div>
      </div>
    </Modal>
  );
}

export default MediumEndLiveModal;
