import React from 'react';
import { EVENT_KEYS } from '../../constants';
import { EVENT_KEYS_EDITABLE } from '../basketball_5x5/constants';
import UpdatePlayerStatForm from './PayloadForms/UpdatePlayerStatForm';
import { GameState } from '../../types';

interface PayloadFormProps {
  eventKey: string;
  gameState: GameState;
  initialPayload?: Record<string, any>;
  onPayloadChange: (updateFn: (prevPayload: any) => any) => void;
}

const PayloadForm: React.FC<PayloadFormProps> = ({
  eventKey,
  gameState,
  initialPayload = {},
  onPayloadChange,
}) => {
  if (!EVENT_KEYS_EDITABLE.includes(eventKey)) {
    return <></>;
  }

  switch (eventKey) {
    case EVENT_KEYS.UPDATE_PLAYER_STAT:
      return (
        <UpdatePlayerStatForm
          onChange={onPayloadChange}
          gameState={gameState}
          initialPayload={initialPayload}
        />
      );
    case EVENT_KEYS.UPDATE_COACH_STAT:
      return <></>;
    case EVENT_KEYS.UPDATE_TEAM_STAT:
      return <></>;
    default:
      return <></>;
  }
};

export default PayloadForm;
