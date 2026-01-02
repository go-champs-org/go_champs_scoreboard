import React from 'react';
import { GameState } from '../../types';
import { BASKETBALL_VIEWS } from './constants';
import BasicEndLiveModal from './EndLiveModal/BasicEndLiveModal';
import MediumEndLiveModal from './EndLiveModal/MediumEndLiveModal';

interface EndLiveModalProps {
  game_state: GameState;
  showModal: boolean;
  onCloseModal: () => void;
  pushEvent: (event: string, payload: any) => void;
}

function EndLiveModal(props: EndLiveModalProps) {
  const { game_state } = props;

  // Route to appropriate modal based on view type
  switch (game_state.view_settings_state.view) {
    case BASKETBALL_VIEWS.BASIC:
      return <BasicEndLiveModal {...props} />;
    case BASKETBALL_VIEWS.MEDIUM:
      return <MediumEndLiveModal {...props} />;
    default:
      // Fallback to basic for unknown view types
      return <BasicEndLiveModal {...props} />;
  }
}

export default EndLiveModal;
