import React from 'react';
import { useTranslation } from 'react-i18next';
import { GameState } from '../../../types';
import { ApiOfficial } from '../../../goChampsApiTypes';
import { useConfig } from '../../../shared/Config';
import officialsHttpClient from '../../../features/officials/officialsHttpClient';
import Modal from '../../Modal';
import AddOfficialRow from './AddOfficialRow';
import EditOfficialRow from './EditOfficialRow';
import FormField from '../../FormField';
import DateTimeInput from '../../shared/form/DateTimeInput';

type TabType = 'officials' | 'gameInfo' | 'gameReport';

interface GameInfoTabProps {
  game_state: GameState;
  pushEvent: (event: string, data: any) => void;
}

function GameInfoTab({ game_state, pushEvent }: GameInfoTabProps) {
  const { t } = useTranslation();
  const handleLocationUpdate = (location: string) => {
    if (location !== (game_state.info.location || '')) {
      pushEvent('update-game-info', { location });
    }
  };

  const handleNumberUpdate = (number: string) => {
    if (number !== (game_state.info.number || '')) {
      pushEvent('update-game-info', { number });
    }
  };

  const handleStartedAtUpdate = (started_at: string | null) => {
    if (started_at !== game_state.clock_state.started_at) {
      pushEvent('update-clock-state-metadata', { started_at });
    }
  };

  const handleFinishedAtUpdate = (finished_at: string | null) => {
    if (finished_at !== game_state.clock_state.finished_at) {
      pushEvent('update-clock-state-metadata', { finished_at });
    }
  };

  return (
    <div className="content">
      <div className="field">
        <label className="label">{t('basketball.game.modal.location')}</label>
        <div className="control">
          <FormField
            initialValue={game_state.info.location}
            onChange={handleLocationUpdate}
            render={(value, onChange) => (
              <input
                className="input"
                type="text"
                value={value}
                placeholder={t('basketball.game.modal.locationPlaceholder')}
                onChange={onChange}
              />
            )}
          />
        </div>
      </div>

      <div className="field">
        <label className="label">{t('basketball.game.modal.number')}</label>
        <div className="control">
          <FormField
            initialValue={game_state.info.number}
            onChange={handleNumberUpdate}
            render={(value, onChange) => (
              <input
                className="input"
                type="text"
                value={value}
                placeholder={t('basketball.game.modal.numberPlaceholder')}
                onChange={onChange}
              />
            )}
          />
        </div>
      </div>

      <div className="field">
        <label className="label">{t('basketball.game.modal.startedAt')}</label>
        <div className="control">
          <DateTimeInput
            value={game_state.clock_state.started_at}
            onChange={handleStartedAtUpdate}
            dateLabel={t('basketball.game.modal.date')}
            timeLabel={t('basketball.game.modal.time')}
          />
        </div>
      </div>

      <div className="field">
        <label className="label">{t('basketball.game.modal.finishedAt')}</label>
        <div className="control">
          <DateTimeInput
            value={game_state.clock_state.finished_at}
            onChange={handleFinishedAtUpdate}
            dateLabel={t('basketball.game.modal.date')}
            timeLabel={t('basketball.game.modal.time')}
          />
        </div>
      </div>
    </div>
  );
}

interface GameReportTabProps {
  game_state: GameState;
  pushEvent: (event: string, data: any) => void;
}

function GameReportTab({ game_state, pushEvent }: GameReportTabProps) {
  const { t } = useTranslation();
  const [gameReport, setGameReport] = React.useState(
    game_state.info.game_report || '',
  );

  const handleSave = () => {
    pushEvent('update-game-info', { game_report: gameReport });
  };

  const handleTextareaChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setGameReport(e.target.value);
  };

  return (
    <div className="content">
      <div className="field">
        <label className="label">{t('basketball.game.modal.gameReport')}</label>
        <div className="control">
          <textarea
            className="textarea"
            rows={10}
            value={gameReport}
            onChange={handleTextareaChange}
            placeholder={t('basketball.game.modal.gameReportPlaceholder')}
          />
        </div>
      </div>

      <div className="field">
        <div className="control">
          <button className="button is-primary" onClick={handleSave}>
            {t('basketball.game.modal.saveGameReport')}
          </button>
        </div>
      </div>
    </div>
  );
}

interface OfficialsTabProps {
  game_state: GameState;
  showAddOfficialRow: boolean;
  pushEvent: (event: string, data: any) => void;
  setShowAddOfficialRow: (show: boolean) => void;
  tournamentOfficials: ApiOfficial[];
  loadingOfficials: boolean;
}

function OfficialsTab({
  game_state,
  showAddOfficialRow,
  pushEvent,
  setShowAddOfficialRow,
  tournamentOfficials,
  loadingOfficials,
}: OfficialsTabProps) {
  const { t } = useTranslation();

  if (loadingOfficials) {
    return (
      <div className="loading-container">
        <div className="loader"></div>
      </div>
    );
  }

  return (
    <div>
      <div className="has-text-right mb-4">
        <button
          className="button is-info is-small"
          onClick={() => setShowAddOfficialRow(true)}
        >
          {t('basketball.officials.modal.addOfficial')}
        </button>
      </div>

      <div className="table-container">
        <table className="table is-fullwidth">
          <thead>
            <tr>
              <th style={{ minWidth: '140px', maxWidth: '140px' }}>
                {t('basketball.officials.modal.name')}
              </th>
              <th style={{ minWidth: '140px', maxWidth: '140px' }}>
                {t('basketball.officials.modal.type')}
              </th>
              <th style={{ minWidth: '65px', maxWidth: '65px' }}>
                {t('basketball.officials.modal.licenseNumber')}
              </th>
              <th style={{ minWidth: '65px', maxWidth: '65px' }}>
                {t('basketball.officials.modal.federation')}
              </th>
              <th style={{ minWidth: '50px', maxWidth: '50px' }}>
                {t('basketball.officials.modal.edit')}
              </th>
              <th style={{ minWidth: '50px', maxWidth: '50px' }}>
                {t('basketball.officials.modal.delete')}
              </th>
            </tr>
          </thead>
          <tbody>
            {showAddOfficialRow && (
              <AddOfficialRow
                pushEvent={pushEvent}
                onConfirmAction={() => setShowAddOfficialRow(false)}
                tournamentOfficials={tournamentOfficials}
              />
            )}
            {game_state.officials.map((official) => (
              <EditOfficialRow
                key={official.id}
                official={official}
                pushEvent={pushEvent}
                tournamentOfficials={tournamentOfficials}
              />
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

interface EditGameModalProps {
  game_state: GameState;
  showModal: boolean;
  onCloseModal: () => void;
  pushEvent: (event: string, payload: any) => void;
}

function EditGameModal({
  onCloseModal,
  showModal,
  game_state,
  pushEvent,
}: EditGameModalProps) {
  const { t } = useTranslation();
  const config = useConfig();
  const [showAddOfficialRow, setShowAddOfficialRow] = React.useState(false);
  const [activeTab, setActiveTab] = React.useState<TabType>('officials');
  const [tournamentOfficials, setTournamentOfficials] = React.useState<
    ApiOfficial[]
  >([]);
  const [loadingOfficials, setLoadingOfficials] = React.useState(false);

  // Load tournament officials when modal opens
  React.useEffect(() => {
    if (showModal && game_state.info.tournament_id) {
      setLoadingOfficials(true);
      officialsHttpClient
        .fetchTournamentOfficials(
          config.getApiHost(),
          game_state.info.tournament_id,
        )
        .then((response) => {
          setTournamentOfficials(response.data);
        })
        .catch((error) => {
          console.error('Failed to load tournament officials:', error);
          // Silently fall back to empty list
          setTournamentOfficials([]);
        })
        .finally(() => {
          setLoadingOfficials(false);
        });
    }
  }, [showModal, game_state.info.tournament_id, config]);

  return (
    <Modal
      title={t('basketball.game.modal.title')}
      onClose={onCloseModal}
      showModal={showModal}
      modalCardStyle={{ width: '800px' }}
    >
      <div className="edit-game-modal">
        <div className="tabs is-boxed">
          <ul>
            <li className={activeTab === 'officials' ? 'is-active' : ''}>
              <a onClick={() => setActiveTab('officials')}>
                {t('basketball.game.modal.officialsTab')}
              </a>
            </li>
            <li className={activeTab === 'gameInfo' ? 'is-active' : ''}>
              <a onClick={() => setActiveTab('gameInfo')}>
                {t('basketball.game.modal.gameInfoTab')}
              </a>
            </li>
            <li className={activeTab === 'gameReport' ? 'is-active' : ''}>
              <a onClick={() => setActiveTab('gameReport')}>
                {t('basketball.game.modal.gameReportTab')}
              </a>
            </li>
          </ul>
        </div>

        <div className="tab-content">
          {activeTab === 'officials' && (
            <OfficialsTab
              game_state={game_state}
              showAddOfficialRow={showAddOfficialRow}
              pushEvent={pushEvent}
              setShowAddOfficialRow={setShowAddOfficialRow}
              tournamentOfficials={tournamentOfficials}
              loadingOfficials={loadingOfficials}
            />
          )}
          {activeTab === 'gameInfo' && (
            <GameInfoTab game_state={game_state} pushEvent={pushEvent} />
          )}
          {activeTab === 'gameReport' && (
            <GameReportTab game_state={game_state} pushEvent={pushEvent} />
          )}
        </div>
      </div>
    </Modal>
  );
}

export default EditGameModal;
