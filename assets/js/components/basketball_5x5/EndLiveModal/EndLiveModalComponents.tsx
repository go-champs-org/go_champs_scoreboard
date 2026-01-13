import React from 'react';
import { useTranslation } from 'react-i18next';
import {
  PROCESSING_STATES,
  REPORT_STATUSES,
  ReportItem as ReportItemType,
  ProcessingStateManager,
} from './processingState';

// Sub-components
interface ReportStatusIconProps {
  status: string;
}

export function ReportStatusIcon({ status }: ReportStatusIconProps) {
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

export function ReportItem({ report }: ReportItemProps) {
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

export function ReportsList({ reports }: ReportsListProps) {
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

export function ProcessingMessage() {
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

export function ErrorDisplay({ error }: ErrorDisplayProps) {
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

export function ModalFooter({
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
