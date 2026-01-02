import React from 'react';
import Modal from '../../Modal';
import { useTranslation } from 'react-i18next';
import { GameState } from '../../../types';
import { shouldShowEarlyEndWarning } from './timeValidation';
import { executeBasicEndLive, EndLiveCallbacks } from './endLiveFlows';

interface BasicEndLiveModalProps {
  game_state: GameState;
  showModal: boolean;
  onCloseModal: () => void;
  pushEvent: (event: string, payload: any) => void;
}

function BasicEndLiveModal({
  game_state,
  showModal,
  onCloseModal,
  pushEvent,
}: BasicEndLiveModalProps) {
  const { t } = useTranslation();

  const shouldShowWarning = shouldShowEarlyEndWarning(
    game_state.live_state.started_at,
  );

  const handleEndLive = () => {
    const callbacks: EndLiveCallbacks = {
      pushEvent,
      onCloseModal,
    };
    executeBasicEndLive(callbacks);
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
          <button className="button is-danger is-small" onClick={handleEndLive}>
            {t('basketball.modals.endLiveConfirmation.endLive')}
          </button>
        </div>
      </div>
    </Modal>
  );
}

export default BasicEndLiveModal;
