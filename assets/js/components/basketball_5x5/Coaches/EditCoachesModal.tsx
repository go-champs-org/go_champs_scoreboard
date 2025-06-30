import React from 'react';
import { GameState, TeamState, TeamType } from '../../../types';
import Modal from '../../Modal';
import AddCoachRow from './AddCoachRow';

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
  return (
    <div>
      <div className="table-container">
        <table className="table is-fullwidth">
          <thead>
            <tr>
              <th style={{ minWidth: '140px', maxWidth: '140px' }}>Name</th>
              <th style={{ minWidth: '140px', maxWidth: '140px' }}>Type</th>
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
            {team.coaches.map((coach, index) => (
              <tr key={index}>
                <td>{coach.name}</td>
                <td>{coach.type}</td>
              </tr>
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
  const [activeTab, setActiveTab] = React.useState('away' as TeamType);
  const [showAddCoachRow, setShowAddCoachRow] = React.useState(false);
  const selectedTeam =
    activeTab === 'away' ? game_state.away_team : game_state.home_team;
  return (
    <Modal title="Edit Coaches" showModal={showModal} onClose={onCloseModal}>
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
            Add Coach
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
