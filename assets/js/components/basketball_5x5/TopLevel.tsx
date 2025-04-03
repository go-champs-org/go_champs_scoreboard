import React from 'react';

import { GameState } from '../../types';
import Modal from '../Modal';
import BoxScore from './BoxScore';
import EditPlayersModal from './Players/EditPlayersModal';
import useConnectionState from '../../shared/useConnectionState';
import { OnlineIcon, OfflineIcon } from '../../shared/ConnectionStatusesIcon';

interface TopLevelProps {
  game_state: GameState;
  pushEvent: (event: string, payload: any) => void;
}

function TopLevel({ game_state, pushEvent }: TopLevelProps) {
  const [showBoxScoreModal, setShowBoxScoreModal] = React.useState(false);
  const [showEditPlayersModal, setShowEditPlayersModal] = React.useState(false);
  const [showEndLiveWarningModal, setShowEndLiveWarningModal] =
    React.useState(false);
  const onStartLive = () => {
    pushEvent('start-game-live-mode', {});
  };
  const onEndLive = () => {
    const startedAt = new Date(game_state.live_state.started_at); // Parse the UTC date
    const now = new Date(); // Current local time
    const fortyFiveMinutesInMs = 45 * 60 * 1000; // 45 minutes in milliseconds

    debugger;
    if (now.getTime() - startedAt.getTime() > fortyFiveMinutesInMs) {
      pushEvent('end-game-live-mode', {});
      return;
    } else {
      setShowEndLiveWarningModal(true);
    }
  };

  const liveSocket = useConnectionState();

  return (
    <nav className="level">
      <div className="level-left">
        <p className="level-item">
          <button
            className="button is-info"
            onClick={() => setShowBoxScoreModal(true)}
          >
            Box score
          </button>
        </p>
        <p>
          <button
            className="button is-info"
            onClick={() => setShowEditPlayersModal(true)}
          >
            Edit players
          </button>
        </p>
        <Modal
          title="Box Score"
          onClose={() => setShowBoxScoreModal(false)}
          showModal={showBoxScoreModal}
          modalCardStyle={{ width: '1024px' }}
        >
          <BoxScore game_state={game_state} />
        </Modal>
        <EditPlayersModal
          game_state={game_state}
          showModal={showEditPlayersModal}
          onCloseModal={() => setShowEditPlayersModal(false)}
          pushEvent={pushEvent}
        />
        <Modal
          title="Are you sure?"
          onClose={() => setShowEndLiveWarningModal(false)}
          showModal={showEndLiveWarningModal}
        >
          <>
            <p>
              Are you sure you want to end the live mode? The game will be
              considered finished and you will not be able to start it again.
            </p>
            <div className="modal-card-foot">
              <button
                className="button is-danger"
                onClick={() => {
                  pushEvent('end-game-live-mode', {});
                  setShowEndLiveWarningModal(false);
                }}
              >
                End Live
              </button>
              <button
                className="button"
                onClick={() => setShowEndLiveWarningModal(false)}
              >
                Cancel
              </button>
            </div>
          </>
        </Modal>
      </div>

      <div className="level-right">
        {game_state.view_settings_state.view !== 'basketball-basic' && (
          <p className="level-item">
            <a
              className="button is-info"
              href={`/scoreboard/stream_views/${game_state.id}`}
              target="_blank"
            >
              Stream Views (OBS)
            </a>
          </p>
        )}
        <p className="level-item">
          {liveSocket === 'connected' ? <OnlineIcon /> : <OfflineIcon />}
        </p>
        <p className="level-item">
          {game_state.live_state.state === 'in_progress' ? (
            <button className="button is-danger" onClick={onEndLive}>
              End Live
            </button>
          ) : (
            <button className="button is-success" onClick={onStartLive}>
              Start Live
            </button>
          )}
        </p>
      </div>
    </nav>
  );
}

export default TopLevel;
