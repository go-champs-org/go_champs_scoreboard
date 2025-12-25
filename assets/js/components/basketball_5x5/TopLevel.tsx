import React from 'react';

import { GameState } from '../../types';
import Modal from '../Modal';
import BoxScore from './BoxScore';
import EditPlayersModal from './Players/EditPlayersModal';
import EditCoachesModal from './Coaches/EditCoachesModal';
import useConnectionState from '../../shared/useConnectionState';
import { OnlineIcon, OfflineIcon } from '../../shared/ConnectionStatusesIcon';
import EventLogModal from '../event_log/EventLogModal';
import EditGameModal from './Officials/EditGameModal';
import LanguageSwitcher from '../LanguageSwitcher';
import { useTranslation } from '../../hooks/useTranslation';

interface TopLevelProps {
  game_state: GameState;
  pushEvent: (event: string, payload: any) => void;
}

function TopLevel({ game_state, pushEvent }: TopLevelProps) {
  const { t } = useTranslation();
  const [showBoxScoreModal, setShowBoxScoreModal] = React.useState(false);
  const [showEditPlayersModal, setShowEditPlayersModal] = React.useState(false);
  const [showEditCoachesModal, setShowEditCoachesModal] = React.useState(false);
  const [showEditGameModal, setShowEditGameModal] = React.useState(false);
  const [showEndLiveWarningModal, setShowEndLiveWarningModal] =
    React.useState(false);
  const onStartLive = () => {
    pushEvent('start-game-live-mode', {});
  };
  const [showEventLogModal, setShowEventLogModal] = React.useState(false);
  const onEndLive = () => {
    const startedAt = new Date(game_state.live_state.started_at); // Parse the UTC date
    const now = new Date(); // Current local time
    const fortyFiveMinutesInMs = 45 * 60 * 1000; // 45 minutes in milliseconds

    if (now.getTime() - startedAt.getTime() > fortyFiveMinutesInMs) {
      pushEvent('end-game-live-mode', {});
      return;
    } else {
      setShowEndLiveWarningModal(true);
    }
  };

  const liveSocket = useConnectionState();

  return (
    <nav className="level nav-level">
      <div className="level-left">
        <img
          src="/images/go-champs-logo.png"
          alt="Go Champs"
          width={32}
          height={32}
        />
        <p className="level-item">
          <button
            className="button is-info is-small"
            onClick={() => setShowBoxScoreModal(true)}
          >
            {t('basketball.navigation.boxScore')}
          </button>
        </p>
        <p className="level-item">
          <button
            className="button is-info is-small"
            onClick={() => setShowEditPlayersModal(true)}
          >
            {t('basketball.navigation.editPlayers')}
          </button>
        </p>
        {game_state.view_settings_state.view !== 'basketball-basic' && (
          <p className="level-item">
            <button
              className="button is-info is-small"
              onClick={() => setShowEditCoachesModal(true)}
            >
              {t('basketball.navigation.editCoaches')}
            </button>
          </p>
        )}
        {game_state.view_settings_state.view !== 'basketball-basic' && (
          <p className="level-item">
            <button
              className="button is-info is-small"
              onClick={() => setShowEditGameModal(true)}
            >
              {t('basketball.navigation.editGame')}
            </button>
          </p>
        )}
        <p className="level-item">
          <button
            className="button is-info is-small"
            onClick={() => setShowEventLogModal(true)}
          >
            {t('basketball.navigation.eventLogs')}
          </button>
        </p>
        {game_state.view_settings_state.view !== 'basketball-basic' && (
          <p className="level-item">
            <button
              className="button is-info is-small"
              disabled={game_state.live_state.state === 'not_started'}
              onClick={() => {
                if (game_state.live_state.state !== 'not_started') {
                  window.open(
                    `/scoreboard/report_viewer/${game_state.id}?report_slug=fiba-scoresheet`,
                    '_blank',
                  );
                }
              }}
            >
              {t('basketball.navigation.fibaScoresheet')}
            </button>
          </p>
        )}
        <Modal
          title={t('basketball.navigation.boxScore')}
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
        <EditCoachesModal
          game_state={game_state}
          showModal={showEditCoachesModal}
          onCloseModal={() => setShowEditCoachesModal(false)}
          pushEvent={pushEvent}
        />
        <EditGameModal
          game_state={game_state}
          showModal={showEditGameModal}
          onCloseModal={() => setShowEditGameModal(false)}
          pushEvent={pushEvent}
        />
        <EventLogModal
          game_state={game_state}
          onCloseModal={() => setShowEventLogModal(false)}
          showModal={showEventLogModal}
        />
        <Modal
          title={t('basketball.modals.endLiveConfirmation.title')}
          onClose={() => setShowEndLiveWarningModal(false)}
          showModal={showEndLiveWarningModal}
        >
          <>
            <p>{t('basketball.modals.endLiveConfirmation.message')}</p>
            <div className="modal-card-foot">
              <button
                className="button is-danger is-small"
                onClick={() => {
                  pushEvent('end-game-live-mode', {});
                  setShowEndLiveWarningModal(false);
                }}
              >
                {t('basketball.modals.endLiveConfirmation.endLive')}
              </button>
              <button
                className="button is-small"
                onClick={() => setShowEndLiveWarningModal(false)}
              >
                {t('basketball.modals.endLiveConfirmation.cancel')}
              </button>
            </div>
          </>
        </Modal>
      </div>

      <div className="level-right">
        <p className="level-item">
          <LanguageSwitcher />
        </p>
        <p className="level-item">
          {liveSocket === 'connected' ? <OnlineIcon /> : <OfflineIcon />}
        </p>
        {game_state.view_settings_state.view !== 'basketball-basic' && (
          <p className="level-item">
            <a
              className="button is-info is-small"
              href={`/scoreboard/stream_views/${game_state.id}`}
              target="_blank"
            >
              {t('basketball.navigation.streamViews')}
            </a>
          </p>
        )}
        <p className="level-item">
          {game_state.live_state.state === 'in_progress' ? (
            <button className="button is-danger is-small" onClick={onEndLive}>
              {t('basketball.navigation.endLive')}
            </button>
          ) : (
            <button
              className="button is-success is-small"
              onClick={onStartLive}
            >
              {t('basketball.navigation.startLive')}
            </button>
          )}
        </p>
      </div>
    </nav>
  );
}

export default TopLevel;
