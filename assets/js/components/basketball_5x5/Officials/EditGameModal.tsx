import React from 'react';
import { useTranslation } from 'react-i18next';
import { GameState } from '../../../types';
import Modal from '../../Modal';
import AddOfficialRow from './AddOfficialRow';
import EditOfficialRow from './EditOfficialRow';
import FormField from '../../FormField';
import DateTimeInput from '../../shared/form/DateTimeInput';

type TabType = 'officials' | 'gameInfo';

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

interface OfficialsTabProps {
  game_state: GameState;
  showAddOfficialRow: boolean;
  pushEvent: (event: string, data: any) => void;
  setShowAddOfficialRow: (show: boolean) => void;
}

function OfficialsTab({
  game_state,
  showAddOfficialRow,
  pushEvent,
  setShowAddOfficialRow,
}: OfficialsTabProps) {
  const { t } = useTranslation();
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
              />
            )}
            {game_state.officials.map((official) => (
              <EditOfficialRow
                key={official.id}
                official={official}
                pushEvent={pushEvent}
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
  const [showAddOfficialRow, setShowAddOfficialRow] = React.useState(false);
  const [activeTab, setActiveTab] = React.useState<TabType>('officials');

  return (
    <Modal
      title={t('basketball.game.modal.title')}
      onClose={onCloseModal}
      showModal={showModal}
      modalCardStyle={{ width: '800px' }}
    >
      <div className="tabs">
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
        </ul>
      </div>

      <div className="tab-content">
        {activeTab === 'officials' && (
          <OfficialsTab
            game_state={game_state}
            showAddOfficialRow={showAddOfficialRow}
            pushEvent={pushEvent}
            setShowAddOfficialRow={setShowAddOfficialRow}
          />
        )}
        {activeTab === 'gameInfo' && (
          <GameInfoTab game_state={game_state} pushEvent={pushEvent} />
        )}
      </div>
    </Modal>
  );
}

export default EditGameModal;
