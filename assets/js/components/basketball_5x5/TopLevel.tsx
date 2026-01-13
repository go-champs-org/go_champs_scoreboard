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
import EndLiveModal from './EndLiveModal';
import SignatureModal from './Reports/SignatureModal';
import { REPORT_SLUGS } from '../../shared/reportRegistry';
import { BASKETBALL_VIEWS } from './constants';

interface ReportsProps {
  game_state: GameState;
  t: (key: string) => string;
  pushEvent: (event: string, payload: any) => void;
}

function MediumPlusReports({ game_state, t, pushEvent }: ReportsProps) {
  const [showFibaDropdown, setShowFibaDropdown] = React.useState(false);
  const [showSignatureModal, setShowSignatureModal] = React.useState(false);

  // Close dropdown when clicking outside
  React.useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      const dropdown = (event.target as Element)?.closest('.dropdown');
      if (!dropdown) {
        setShowFibaDropdown(false);
      }
    };

    if (showFibaDropdown) {
      document.addEventListener('click', handleClickOutside);
      return () => document.removeEventListener('click', handleClickOutside);
    }
  }, [showFibaDropdown]);

  const handleSignatureClick = () => {
    setShowFibaDropdown(false);
    setShowSignatureModal(true);
  };

  return (
    <>
      <div className={`dropdown ${showFibaDropdown ? 'is-active' : ''}`}>
        <div className="dropdown-trigger">
          <button
            className="button is-info is-small"
            disabled={game_state.live_state.state === 'not_started'}
            aria-haspopup="true"
            aria-controls="dropdown-menu"
            onClick={() => setShowFibaDropdown(!showFibaDropdown)}
          >
            <span>{t('basketball.navigation.reports')}</span>
          </button>
        </div>
        <div className="dropdown-menu" id="dropdown-menu" role="menu">
          <div className="dropdown-content">
            <a
              className="dropdown-item"
              onClick={() => {
                if (game_state.live_state.state !== 'not_started') {
                  window.open(
                    `/scoreboard/report_viewer/${game_state.id}?report_slug=${REPORT_SLUGS.FIBA_SCORESHEET}`,
                    '_blank',
                  );
                }
                setShowFibaDropdown(false);
              }}
            >
              {t('basketball.reports.fibaScoresheet')}
            </a>
            <a
              className="dropdown-item"
              onClick={() => {
                if (game_state.live_state.state !== 'not_started') {
                  window.open(
                    `/scoreboard/report_viewer/${game_state.id}?report_slug=${REPORT_SLUGS.FIBA_BOXSCORE}`,
                    '_blank',
                  );
                }
                setShowFibaDropdown(false);
              }}
            >
              {t('basketball.reports.fibaBoxScore.title')}
            </a>
            <a className="dropdown-item" onClick={handleSignatureClick}>
              {t('basketball.reports.collectSignatures')}
            </a>
          </div>
        </div>
      </div>

      <SignatureModal
        game_state={game_state}
        showModal={showSignatureModal}
        onCloseModal={() => setShowSignatureModal(false)}
        pushEvent={pushEvent}
      />
    </>
  );
}

function MediumReports({ game_state, t, pushEvent }: ReportsProps) {
  const [showFibaDropdown, setShowFibaDropdown] = React.useState(false);

  // Close dropdown when clicking outside
  React.useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      const dropdown = (event.target as Element)?.closest('.dropdown');
      if (!dropdown) {
        setShowFibaDropdown(false);
      }
    };

    if (showFibaDropdown) {
      document.addEventListener('click', handleClickOutside);
      return () => document.removeEventListener('click', handleClickOutside);
    }
  }, [showFibaDropdown]);

  return (
    <>
      <div className={`dropdown ${showFibaDropdown ? 'is-active' : ''}`}>
        <div className="dropdown-trigger">
          <button
            className="button is-info is-small"
            disabled={game_state.live_state.state === 'not_started'}
            aria-haspopup="true"
            aria-controls="dropdown-menu"
            onClick={() => setShowFibaDropdown(!showFibaDropdown)}
          >
            <span>{t('basketball.navigation.reports')}</span>
          </button>
        </div>
        <div className="dropdown-menu" id="dropdown-menu" role="menu">
          <div className="dropdown-content">
            <a
              className="dropdown-item"
              onClick={() => {
                if (game_state.live_state.state !== 'not_started') {
                  window.open(
                    `/scoreboard/report_viewer/${game_state.id}?report_slug=${REPORT_SLUGS.FIBA_BOXSCORE}`,
                    '_blank',
                  );
                }
                setShowFibaDropdown(false);
              }}
            >
              {t('basketball.reports.fibaBoxScore.title')}
            </a>
          </div>
        </div>
      </div>
    </>
  );
}

interface TopLevelProps {
  game_state: GameState;
  pushEvent: (event: string, payload: any) => void;
}

function BasicTopLevel({ game_state, pushEvent }: TopLevelProps) {
  const { t } = useTranslation();
  const [showBoxScoreModal, setShowBoxScoreModal] = React.useState(false);
  const [showEditPlayersModal, setShowEditPlayersModal] = React.useState(false);
  const [showEndLiveWarningModal, setShowEndLiveWarningModal] =
    React.useState(false);
  const onStartLive = () => {
    pushEvent('start-game-live-mode', {});
  };
  const [showEventLogModal, setShowEventLogModal] = React.useState(false);
  const liveSocket = useConnectionState();

  return (
    <nav className="level nav-level top-level">
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
        <p className="level-item">
          <button
            className="button is-info is-small"
            onClick={() => setShowEventLogModal(true)}
          >
            {t('basketball.navigation.eventLogs')}
          </button>
        </p>
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
        <EventLogModal
          game_state={game_state}
          onCloseModal={() => setShowEventLogModal(false)}
          showModal={showEventLogModal}
        />
        <EndLiveModal
          game_state={game_state}
          showModal={showEndLiveWarningModal}
          onCloseModal={() => setShowEndLiveWarningModal(false)}
          pushEvent={pushEvent}
        />
      </div>

      <div className="level-right">
        <div className="level-item">
          <LanguageSwitcher />
        </div>
        <p className="level-item">
          {liveSocket === 'connected' ? <OnlineIcon /> : <OfflineIcon />}
        </p>
        <p className="level-item">
          {game_state.live_state.state === 'in_progress' ? (
            <button
              className="button is-danger is-small"
              onClick={() => setShowEndLiveWarningModal(true)}
            >
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

function MediumTopLevel({ game_state, pushEvent }: TopLevelProps) {
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
  const liveSocket = useConnectionState();

  return (
    <nav className="level nav-level top-level">
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
        <p className="level-item">
          <button
            className="button is-info is-small"
            onClick={() => setShowEditCoachesModal(true)}
          >
            {t('basketball.navigation.editCoaches')}
          </button>
        </p>
        <p className="level-item">
          <button
            className="button is-info is-small"
            onClick={() => setShowEditGameModal(true)}
          >
            {t('basketball.navigation.editGame')}
          </button>
        </p>
        <p className="level-item">
          <button
            className="button is-info is-small"
            onClick={() => setShowEventLogModal(true)}
          >
            {t('basketball.navigation.eventLogs')}
          </button>
        </p>
        <div className="level-item">
          <MediumReports game_state={game_state} t={t} pushEvent={pushEvent} />
        </div>
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
        <EndLiveModal
          game_state={game_state}
          showModal={showEndLiveWarningModal}
          onCloseModal={() => setShowEndLiveWarningModal(false)}
          pushEvent={pushEvent}
        />
      </div>

      <div className="level-right">
        <div className="level-item">
          <LanguageSwitcher />
        </div>
        <p className="level-item">
          {liveSocket === 'connected' ? <OnlineIcon /> : <OfflineIcon />}
        </p>
        <p className="level-item">
          <a
            className="button is-info is-small"
            href={`/scoreboard/stream_views/${game_state.id}`}
            target="_blank"
          >
            {t('basketball.navigation.streamViews')}
          </a>
        </p>
        <p className="level-item">
          {game_state.live_state.state === 'in_progress' ? (
            <button
              className="button is-danger is-small"
              onClick={() => setShowEndLiveWarningModal(true)}
            >
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

function MediumPlusTopLevel({ game_state, pushEvent }: TopLevelProps) {
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
  const liveSocket = useConnectionState();

  return (
    <nav className="level nav-level top-level">
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
        <p className="level-item">
          <button
            className="button is-info is-small"
            onClick={() => setShowEditCoachesModal(true)}
          >
            {t('basketball.navigation.editCoaches')}
          </button>
        </p>
        <p className="level-item">
          <button
            className="button is-info is-small"
            onClick={() => setShowEditGameModal(true)}
          >
            {t('basketball.navigation.editGame')}
          </button>
        </p>
        <p className="level-item">
          <button
            className="button is-info is-small"
            onClick={() => setShowEventLogModal(true)}
          >
            {t('basketball.navigation.eventLogs')}
          </button>
        </p>
        <div className="level-item">
          <MediumPlusReports
            game_state={game_state}
            t={t}
            pushEvent={pushEvent}
          />
        </div>
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
        <EndLiveModal
          game_state={game_state}
          showModal={showEndLiveWarningModal}
          onCloseModal={() => setShowEndLiveWarningModal(false)}
          pushEvent={pushEvent}
        />
      </div>

      <div className="level-right">
        <div className="level-item">
          <LanguageSwitcher />
        </div>
        <p className="level-item">
          {liveSocket === 'connected' ? <OnlineIcon /> : <OfflineIcon />}
        </p>
        <p className="level-item">
          <a
            className="button is-info is-small"
            href={`/scoreboard/stream_views/${game_state.id}`}
            target="_blank"
          >
            {t('basketball.navigation.streamViews')}
          </a>
        </p>
        <p className="level-item">
          {game_state.live_state.state === 'in_progress' ? (
            <button
              className="button is-danger is-small"
              onClick={() => setShowEndLiveWarningModal(true)}
            >
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

export { BasicTopLevel, MediumTopLevel, MediumPlusTopLevel };
export default MediumTopLevel;
