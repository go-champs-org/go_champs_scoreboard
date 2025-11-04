import React from 'react';
import { useTranslation } from 'react-i18next';

import { GameState, TeamState, TeamType } from '../../../types';
import Modal from '../../Modal';
import MediumEditPlayerRow, { BasicEditPlayerRow } from './EditPlayerRow';
import AddPlayerRow from './AddPlayerRow';

interface PlayersTableProps {
  team: TeamState;
  teamType: TeamType;
  showAddPlayerRow: boolean;
  pushEvent: (event: string, data: any) => void;
  setShowAddPlayerRow: (show: boolean) => void;
}

function BasicPlayersTable({
  team,
  teamType,
  showAddPlayerRow,
  pushEvent,
  setShowAddPlayerRow,
}: PlayersTableProps) {
  const { t } = useTranslation();
  return (
    <div>
      <div className="table-container">
        <table className="table is-fullwidth">
          <thead>
            <tr>
              <th
                style={{
                  minWidth: '85px',
                  maxWidth: '85px',
                  textAlign: 'center',
                }}
              >
                {t('basketball.players.modal.remove')}
              </th>
              <th style={{ minWidth: '65px', maxWidth: '65px' }}>#</th>
              <th style={{ minWidth: '140px', maxWidth: '140px' }}>
                {t('basketball.players.modal.name')}
              </th>
              <th
                style={{
                  minWidth: '65px',
                  maxWidth: '65px',
                  textAlign: 'center',
                }}
              >
                + 1 {t('basketball.stats.abbreviations.points')}
              </th>
              <th
                style={{
                  minWidth: '65px',
                  maxWidth: '65px',
                  textAlign: 'center',
                }}
              >
                + 2 {t('basketball.stats.abbreviations.points')}
              </th>
              <th
                style={{
                  minWidth: '65px',
                  maxWidth: '65px',
                  textAlign: 'center',
                }}
              >
                + 3 {t('basketball.stats.abbreviations.points')}
              </th>
              <th
                style={{
                  minWidth: '65px',
                  maxWidth: '65px',
                  textAlign: 'center',
                }}
              >
                {t('basketball.stats.abbreviations.rebounds')}
              </th>
              <th
                style={{
                  minWidth: '65px',
                  maxWidth: '65px',
                  textAlign: 'center',
                }}
              >
                {t('basketball.stats.abbreviations.assists')}
              </th>
              <th
                style={{
                  minWidth: '65px',
                  maxWidth: '65px',
                  textAlign: 'center',
                }}
              >
                {t('basketball.stats.abbreviations.blocks')}
              </th>
              <th
                style={{
                  minWidth: '65px',
                  maxWidth: '65px',
                  textAlign: 'center',
                }}
              >
                {t('basketball.stats.abbreviations.steals')}
              </th>
            </tr>
          </thead>
          <tbody>
            {showAddPlayerRow && (
              <AddPlayerRow
                teamType={teamType}
                pushEvent={pushEvent}
                onConfirmAction={() => setShowAddPlayerRow(false)}
              />
            )}
            {team.players.map((player) => (
              <BasicEditPlayerRow
                key={player.id}
                player={player}
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

function MediumPlayersTable({
  team,
  teamType,
  showAddPlayerRow,
  pushEvent,
  setShowAddPlayerRow,
}: PlayersTableProps) {
  const { t } = useTranslation();
  return (
    <div className="table-container">
      <table className="table is-fullwidth">
        <thead>
          <tr>
            <th style={{ minWidth: '85px', maxWidth: '85px' }}>
              {t('basketball.players.modal.remove')}
            </th>
            <th style={{ minWidth: '75px', maxWidth: '75px' }}>
              {t('basketball.players.modal.licenseNumber')}
            </th>
            <th style={{ minWidth: '65px', maxWidth: '65px' }}>#</th>
            <th style={{ minWidth: '140px', maxWidth: '140px' }}>
              {t('basketball.players.modal.name')}
            </th>
            <th style={{ minWidth: '65px', maxWidth: '65px' }}>
              + 1 {t('basketball.stats.abbreviations.points')}
            </th>
            <th style={{ minWidth: '65px', maxWidth: '65px' }}>
              + 2 {t('basketball.stats.abbreviations.points')}
            </th>
            <th style={{ minWidth: '65px', maxWidth: '65px' }}>
              + 3 {t('basketball.stats.abbreviations.points')}
            </th>
            <th style={{ minWidth: '65px', maxWidth: '65px' }}>
              {t('basketball.stats.abbreviations.missOnePoint')}
            </th>
            <th style={{ minWidth: '65px', maxWidth: '65px' }}>
              {t('basketball.stats.abbreviations.missTwoPoints')}
            </th>
            <th style={{ minWidth: '65px', maxWidth: '65px' }}>
              {t('basketball.stats.abbreviations.missThreePoints')}
            </th>
            <th style={{ minWidth: '65px', maxWidth: '65px' }}>
              {t('basketball.stats.abbreviations.assists')}
            </th>
            <th style={{ minWidth: '65px', maxWidth: '65px' }}>
              {t('basketball.stats.abbreviations.blocks')}
            </th>
            <th style={{ minWidth: '65px', maxWidth: '65px' }}>
              {t('basketball.stats.abbreviations.steals')}
            </th>
            <th style={{ minWidth: '65px', maxWidth: '65px' }}>
              {t('basketball.stats.abbreviations.defensiveReboundsShort')}
            </th>
            <th style={{ minWidth: '65px', maxWidth: '65px' }}>
              {t('basketball.stats.abbreviations.offensiveReboundsShort')}
            </th>
            <th style={{ minWidth: '65px', maxWidth: '65px' }}>
              {t('basketball.stats.abbreviations.turnovers')}
            </th>
            <th style={{ minWidth: '65px', maxWidth: '65px' }}>
              {t('basketball.stats.abbreviations.personalFoulsShort')}
            </th>
            <th style={{ minWidth: '65px', maxWidth: '65px' }}>
              {t('basketball.stats.abbreviations.technicalFoulsShort')}
            </th>
            <th style={{ minWidth: '65px', maxWidth: '65px' }}>
              {t('basketball.stats.abbreviations.unsportsmanlikeFoulsShort')}
            </th>
          </tr>
        </thead>
        <tbody>
          {showAddPlayerRow && (
            <AddPlayerRow
              teamType={teamType}
              pushEvent={pushEvent}
              onConfirmAction={() => setShowAddPlayerRow(false)}
            />
          )}
          {team.players.map((player) => (
            <MediumEditPlayerRow
              key={player.id}
              player={player}
              teamType={teamType}
              pushEvent={pushEvent}
            />
          ))}
        </tbody>
      </table>
    </div>
  );
}

interface EditPlayersModalProps {
  game_state: GameState;
  showModal: boolean;
  onCloseModal: () => void;
  pushEvent: (event: string, data: any) => void;
}

function EditPlayersModal({
  game_state,
  showModal,
  onCloseModal,
  pushEvent,
}: EditPlayersModalProps) {
  const { t } = useTranslation();
  const [activeTab, setActiveTab] = React.useState('away' as TeamType);
  const [showAddPlayerRow, setShowAddPlayerRow] = React.useState(false);
  const selectedTeam =
    activeTab === 'away' ? game_state.away_team : game_state.home_team;
  return (
    <Modal
      title={t('basketball.players.modal.title')}
      showModal={showModal}
      onClose={onCloseModal}
      modalCardStyle={{ width: '1024px' }}
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
        <div className="column is-12 has-text-right">
          <button
            className="button is-info is-small"
            onClick={() => setShowAddPlayerRow(true)}
          >
            {t('basketball.players.modal.addPlayer')}
          </button>
        </div>

        <div className="column is-12">
          {game_state.view_settings_state.view === 'basketball-basic' ? (
            <BasicPlayersTable
              team={selectedTeam}
              teamType={activeTab}
              showAddPlayerRow={showAddPlayerRow}
              pushEvent={pushEvent}
              setShowAddPlayerRow={setShowAddPlayerRow}
            />
          ) : (
            <MediumPlayersTable
              team={selectedTeam}
              teamType={activeTab}
              showAddPlayerRow={showAddPlayerRow}
              pushEvent={pushEvent}
              setShowAddPlayerRow={setShowAddPlayerRow}
            />
          )}
        </div>
      </div>
    </Modal>
  );
}

export default EditPlayersModal;
