import React from 'react';

import { GameState } from '../../types';
import Modal from '../Modal';
import BoxScore from './BoxScore';
import EditPlayersModal from './Players/EditPlayersModal';

interface TopLevelProps {
  game_state: GameState;
  pushEvent: (event: string, payload: any) => void;
}

function TopLevel({ game_state, pushEvent }: TopLevelProps) {
  const [showBoxScoreModal, setShowBoxScoreModal] = React.useState(false);
  const [showEditPlayersModal, setShowEditPlayersModal] = React.useState(false);
  const onStartLive = () => {
    pushEvent('start-game-live-mode', {});
  };
  const onEndLive = () => {
    pushEvent('end-game-live-mode', {});
  };

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
