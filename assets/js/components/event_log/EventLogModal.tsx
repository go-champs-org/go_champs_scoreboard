import React from 'react';

import Modal from '../Modal';
import { GameState } from '../../types';
import useEventLogs from '../../features/event_logs/useEventLogs';

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
  const gameId = game_state.id;
  const eventLogs = useEventLogs(gameId);
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
              <th>Period</th>
              <th>Time</th>
              <th>Key</th>
            </tr>
          </thead>
          <tbody>
            {eventLogs.map((eventLog) => (
              <tr key={eventLog.id}>
                <td>{eventLog.game_clock_period}</td>
                <td>{eventLog.game_clock_time}</td>
                <td>{eventLog.key}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </Modal>
  );
}

export default EventLogModal;
