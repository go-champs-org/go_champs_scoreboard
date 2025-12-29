import React from 'react';
import Modal from '../Modal';
import { useTranslation } from 'react-i18next';
import { GameState } from '../../types';
import { BASKETBALL_VIEWS } from './constants';
import { getReportConfig } from '../../shared/reportRegistry';
import { pdf } from '@react-pdf/renderer';
import uploadHttpClient from '../../features/upload/uploadHttpClient';
import { useConfig } from '../../shared/Config';

const FORTY_FIVE_MINUTES_IN_MS = 45 * 60 * 1000; // 45 minutes in milliseconds

const generateAndUploadSimpleExample = async (goChampsApiBaseUrl: string) => {
  const reportConfig = getReportConfig('simple-example');
  const reportData = reportConfig!.parseData('{}');
  const ReportComponent = reportConfig!.component;
  const reportBlob = pdf(<ReportComponent data={reportData} />).toBlob();
  await uploadHttpClient.singAndUpload({
    baseGoChampsApi: goChampsApiBaseUrl,
    file: await reportBlob,
    fileReference: {
      filename: `simple-example.pdf`,
      file_type: 'game-assets',
      content_type: 'application/pdf',
      size: (await reportBlob).size,
    },
    setProgress: (progress: number) => {
      console.log(`Upload progress: ${progress}%`);
    },
    onSucess: (fileReference: any) => {
      console.log('File uploaded successfully:', fileReference);
    },
    onError: () => {
      console.error('Error uploading file');
    },
  });
};

interface EndLiveModalProps {
  game_state: GameState;
  showModal: boolean;
  onCloseModal: () => void;
  pushEvent: (event: string, payload: any) => void;
}

function EndLiveModal({
  game_state,
  showModal,
  onCloseModal,
  pushEvent,
}: EndLiveModalProps) {
  const { t } = useTranslation();
  const [isEnding, setIsEnding] = React.useState(false);
  const config = useConfig();
  const startedAt = new Date(game_state.live_state.started_at); // Parse the UTC date
  const now = new Date(); // Current local time
  const shouldShowWarning =
    now.getTime() - startedAt.getTime() <= FORTY_FIVE_MINUTES_IN_MS;
  const onConfirmEndLive = async () => {
    setIsEnding(true);
    pushEvent('end-game-live-mode', {});
    setIsEnding(false);
  };
  return (
    <Modal
      title={t('basketball.modals.endLiveConfirmation.title')}
      onClose={onCloseModal}
      showModal={showModal}
    >
      <div className="end-live-modal">
        {shouldShowWarning && (
          <div className="warning">
            <p>Jogo com menos de 45 minutos</p>
          </div>
        )}
        <div className="content">
          <p>{t('basketball.modals.endLiveConfirmation.message')}</p>
        </div>
        <div className="footer mt-4 is-flex is-justify-content-flex-end">
          <button className="button is-small" onClick={onCloseModal}>
            {t('basketball.modals.endLiveConfirmation.cancel')}
          </button>
          <button
            className="button is-danger is-small"
            onClick={onConfirmEndLive}
          >
            {t('basketball.modals.endLiveConfirmation.endLive')}
          </button>
        </div>
      </div>
    </Modal>
  );
}

export default EndLiveModal;
