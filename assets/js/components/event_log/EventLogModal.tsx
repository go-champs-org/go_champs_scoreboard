import React, { useTransition } from 'react';

import Modal from '../Modal';
import { GameState } from '../../types';
import useUpdatePlayerStatEventLogs from '../../features/event_logs/useEventLogs';
import { formatTime } from '../../shared/contentHelpers';
import { payloadToString } from './payloadMapper';
import { useTranslation } from 'react-i18next';

interface EventLogModalProps {
  game_state: GameState;
  showModal: boolean;
  onCloseModal: () => void;
  pushEvent: (event: string, data: any) => void;
}

function EventLogModal({
  game_state,
  showModal,
  onCloseModal,
  pushEvent,
}: EventLogModalProps) {
  const { t } = useTranslation();
  const gameId = game_state.id;
  const eventLogs = useUpdatePlayerStatEventLogs(gameId);
  return (
    <Modal
      title="Event logs"
      showModal={showModal}
      onClose={onCloseModal}
      modalCardStyle={{ width: '1024px' }}
    >
      <div className="modal-card-body">
        <table className="table is-striped is-fullwidth">
          <thead>
            <tr>
              <th style={{ width: '50px' }}>Q</th>
              <th style={{ width: '70px' }}>Time</th>
              <th>Event</th>
              <th>Description</th>
            </tr>
          </thead>
          <tbody>
            {eventLogs.map((eventLog) => (
              <tr key={eventLog.id}>
                <td>{eventLog.game_clock_period}</td>
                <td>{formatTime(eventLog.game_clock_time)}</td>
                <td>{eventLog.key}</td>
                <td>
                  {eventLog.payload
                    ? payloadToString(eventLog.payload, game_state, t)
                    : ''}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </Modal>
  );
}

export default EventLogModal;
