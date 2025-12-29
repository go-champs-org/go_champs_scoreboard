import React from 'react';
import Modal from '../Modal';
import { useTranslation } from 'react-i18next';
import { GameState } from '../../types';
import { BASKETBALL_VIEWS } from './constants';
import { useConfig } from '../../shared/Config';
import generatorAndUploaders from './Reports/generatorAndUploaders';

const FORTY_FIVE_MINUTES_IN_MS = 45 * 60 * 1000; // 45 minutes in milliseconds

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
  const [isEnding, setIsEnding] = React.useState(false); // We will use this later to upload files
  const config = useConfig(); // Get config context we - will use this later to upload files
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
            <p>{t('basketball.modals.endLiveConfirmation.endSoonWarning')}</p>
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
