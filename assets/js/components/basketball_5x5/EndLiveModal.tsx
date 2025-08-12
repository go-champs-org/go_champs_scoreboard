import React from 'react';
import Modal from '../Modal';
import { useTranslation } from '../../hooks/useTranslation';

interface EndLiveModalProps {
  showModal: boolean;
}

function EndLiveModal({ showModal }: EndLiveModalProps) {
  const { t } = useTranslation();

  return (
    <Modal
      title={t('basketball.modals.gameEnded.title')}
      showModal={showModal}
      onClose={() => {}}
    >
      {t('basketball.modals.gameEnded.message')}
    </Modal>
  );
}

export default EndLiveModal;
