import React from 'react';
import { useTranslation } from 'react-i18next';
import { GameState, TeamState, TeamType } from '../../../types';
import Modal from '../../Modal';
import EditTeamForm from './EditTeamForm';
import EditTeamCoaches from './EditTeamCoaches';

interface EditTeamsModalProps {
  game_state: GameState;
  showModal: boolean;
  onCloseModal: () => void;
  pushEvent: (event: string, data: any) => void;
}

function EditTeamsModal({
  game_state,
  showModal,
  onCloseModal,
  pushEvent,
}: EditTeamsModalProps) {
  const { t } = useTranslation();
  const [activeTab, setActiveTab] = React.useState<TeamType>('home');
  const [showAddCoachRowHome, setShowAddCoachRowHome] = React.useState(false);
  const [showAddCoachRowAway, setShowAddCoachRowAway] = React.useState(false);

  const selectedTeam =
    activeTab === 'away' ? game_state.away_team : game_state.home_team;
  const showAddCoachRow =
    activeTab === 'home' ? showAddCoachRowHome : showAddCoachRowAway;
  const setShowAddCoachRow =
    activeTab === 'home' ? setShowAddCoachRowHome : setShowAddCoachRowAway;

  const handleTabChange = (newTab: TeamType) => {
    // Reset add coach row state when switching tabs
    setShowAddCoachRowHome(false);
    setShowAddCoachRowAway(false);
    setActiveTab(newTab);
  };

  return (
    <Modal
      title={t('basketball.teams.modal.title')}
      showModal={showModal}
      onClose={onCloseModal}
      modalCardStyle={{ width: '1024px' }}
    >
      <div className="tabs is-boxed">
        <ul>
          <li className={activeTab === 'home' ? 'is-active' : ''}>
            <a onClick={() => handleTabChange('home')}>
              <span>{game_state.home_team.name}</span>
            </a>
          </li>
          <li className={activeTab === 'away' ? 'is-active' : ''}>
            <a onClick={() => handleTabChange('away')}>
              <span>{game_state.away_team.name}</span>
            </a>
          </li>
        </ul>
      </div>

      <div className="columns is-multiline">
        <div className="column is-12">
          <EditTeamForm
            team={selectedTeam}
            teamType={activeTab}
            pushEvent={pushEvent}
          />
        </div>

        <div className="column is-12">
          <EditTeamCoaches
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

export default EditTeamsModal;
