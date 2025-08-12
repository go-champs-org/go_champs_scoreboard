import React from 'react';
import { useTranslation } from 'react-i18next';
import { GameState, TeamState, TeamType } from '../../../types';
import Modal from '../../Modal';
import AddCoachRow from './AddCoachRow';
import EditCoachRow from './EditCoachRow';

interface CoachesTableProps {
  team: TeamState;
  teamType: TeamType;
  showAddCoachRow: boolean;
  pushEvent: (event: string, data: any) => void;
  setShowAddCoachRow: (show: boolean) => void;
}

function CoachesTable({
  team,
  teamType,
  showAddCoachRow,
  pushEvent,
  setShowAddCoachRow,
}: CoachesTableProps) {
  const { t } = useTranslation();
  return (
    <div>
      <div className="table-container">
        <table className="table is-fullwidth">
          <thead>
            <tr>
              <th style={{ minWidth: '140px', maxWidth: '140px' }}>
                {t('basketball.coaches.modal.name')}
              </th>
              <th style={{ minWidth: '140px', maxWidth: '140px' }}>
                {t('basketball.coaches.modal.type')}
              </th>
              <th style={{ minWidth: '65px', maxWidth: '65px' }}>
                {t('basketball.stats.abbreviations.personalFoulsShort')}
              </th>
              <th style={{ minWidth: '65px', maxWidth: '65px' }}>
                {t('basketball.stats.abbreviations.technicalFoulsShort')}
              </th>
              <th style={{ minWidth: '65px', maxWidth: '65px' }}>
                {t('basketball.stats.abbreviations.flagrantFoulsShort')}
              </th>
              <th style={{ minWidth: '50px', maxWidth: '50px' }}>
                {t('basketball.coaches.modal.actions')}
              </th>
            </tr>
          </thead>
          <tbody>
            {showAddCoachRow && (
              <AddCoachRow
                teamType={teamType}
                pushEvent={pushEvent}
                onConfirmAction={() => setShowAddCoachRow(false)}
              />
            )}
            {team.coaches.map((coach) => (
              <EditCoachRow
                key={coach.id}
                coach={coach}
                teamType={teamType}
                pushEvent={pushEvent}
              />
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

interface EditCoachesModalProps {
  game_state: GameState;
  showModal: boolean;
  onCloseModal: () => void;
  pushEvent: (event: string, data: any) => void;
}

function EditCoachesModal({
  game_state,
  showModal,
  onCloseModal,
  pushEvent,
}: EditCoachesModalProps) {
  const { t } = useTranslation();
  const [activeTab, setActiveTab] = React.useState('away' as TeamType);
  const [showAddCoachRow, setShowAddCoachRow] = React.useState(false);
  const selectedTeam =
    activeTab === 'away' ? game_state.away_team : game_state.home_team;
  return (
    <Modal
      title={t('basketball.coaches.modal.title')}
      showModal={showModal}
      onClose={onCloseModal}
    >
      <div className="tabs is-boxed">
        <ul>
          <li className={activeTab === 'away' ? 'is-active' : ''}>
            <a onClick={() => setActiveTab('away')}>
              <span>{game_state.away_team.name}</span>
            </a>
          </li>
          <li className={activeTab === 'home' ? 'is-active' : ''}>
            <a onClick={() => setActiveTab('home')}>
              <span>{game_state.home_team.name}</span>
            </a>
          </li>
        </ul>
      </div>

      <div className="columns is-multiline">
        <div className="column is-12">
          <button className="button" onClick={() => setShowAddCoachRow(true)}>
            {t('basketball.coaches.modal.addCoach')}
          </button>
        </div>

        <div className="column is-12">
          <CoachesTable
            team={selectedTeam}
            teamType={activeTab}
            showAddCoachRow={showAddCoachRow}
            pushEvent={pushEvent}
            setShowAddCoachRow={setShowAddCoachRow}
          />
        </div>
      </div>
    </Modal>
  );
}

export default EditCoachesModal;
