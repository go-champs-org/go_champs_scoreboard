import React from 'react';
import { useTranslation } from 'react-i18next';

import { GameState, TeamState, TeamType, PlayerState } from '../../../types';
import { ApiPlayer } from '../../../goChampsApiTypes';
import { useConfig } from '../../../shared/Config';
import playersHttpClient from '../../../features/players/playersHttpClient';
import Modal from '../../Modal';
import MediumEditPlayerRow, { BasicEditPlayerRow } from './EditPlayerRow';
import AddPlayerRow from './AddPlayerRow';
import { BASKETBALL_VIEWS } from '../constants';
import { useSelectedView } from '../../../shared/ViewSettingsContext';

interface PlayersTableProps {
  team: TeamState;
  teamType: TeamType;
  showAddPlayerRow: boolean;
  pushEvent: (event: string, data: any) => void;
  setShowAddPlayerRow: (show: boolean) => void;
  apiPlayers: ApiPlayer[];
  currentPlayers: PlayerState[];
  onHighlightPlayer: (playerId: string) => void;
  highlightedPlayerId: string | null;
}

function BasicPlayersTable({
  team,
  teamType,
  showAddPlayerRow,
  pushEvent,
  setShowAddPlayerRow,
  apiPlayers,
  currentPlayers,
  onHighlightPlayer,
  highlightedPlayerId,
}: PlayersTableProps) {
  const { t } = useTranslation();

  return (
    <div>
      <div className="table-container">
        <table className="table is-fullwidth">
          <thead>
            <tr>
              <th></th>
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
                numberOfLeadingColumns={2}
                teamType={teamType}
                pushEvent={pushEvent}
                onConfirmAction={() => setShowAddPlayerRow(false)}
                teamPlayers={apiPlayers}
                currentPlayers={currentPlayers}
                onHighlightPlayer={onHighlightPlayer}
              />
            )}
            {team.players.map((player, index) => (
              <BasicEditPlayerRow
                rowNumber={index + 1}
                key={player.id}
                player={player}
                teamType={teamType}
                pushEvent={pushEvent}
                highlighted={player.id === highlightedPlayerId}
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
  currentPlayers,
  onHighlightPlayer,
  highlightedPlayerId,
  pushEvent,
  setShowAddPlayerRow,
  apiPlayers,
}: PlayersTableProps) {
  const { t } = useTranslation();

  return (
    <div className="table-container">
      <table className="table is-fullwidth">
        <thead>
          <tr>
            <th></th>
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
            <th>{t('basketball.players.modal.captain')}</th>
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
              numberOfLeadingColumns={3}
              teamType={teamType}
              pushEvent={pushEvent}
              onConfirmAction={() => setShowAddPlayerRow(false)}
              teamPlayers={apiPlayers}
              currentPlayers={currentPlayers}
              onHighlightPlayer={onHighlightPlayer}
            />
          )}
          {team.players.map((player, index) => (
            <MediumEditPlayerRow
              rowNumber={index + 1}
              key={player.id}
              player={player}
              teamType={teamType}
              pushEvent={pushEvent}
              highlighted={player.id === highlightedPlayerId}
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
  const config = useConfig();
  const goChampsApi = config.getApiHost();
  const [activeTab, setActiveTab] = React.useState('home' as TeamType);
  const [showAddPlayerRow, setShowAddPlayerRow] = React.useState(false);
  const [highlightedPlayerId, setHighlightedPlayerId] = React.useState<
    string | null
  >(null);
  const [homeTeamPlayers, setHomeTeamPlayers] = React.useState<ApiPlayer[]>([]);
  const [awayTeamPlayers, setAwayTeamPlayers] = React.useState<ApiPlayer[]>([]);
  const [loading, setLoading] = React.useState(false);
  const selectedView = useSelectedView();
  const selectedTeam =
    activeTab === 'away' ? game_state.away_team : game_state.home_team;
  const selectedApiPlayers =
    activeTab === 'away' ? awayTeamPlayers : homeTeamPlayers;
  const homeTeamId = game_state.home_team.id;
  const awayTeamId = game_state.away_team.id;

  const handleHighlightPlayer = (playerId: string) => {
    setHighlightedPlayerId(playerId);
    // Clear highlight after 3 seconds
    setTimeout(() => {
      setHighlightedPlayerId(null);
    }, 3000);
  };

  // Fetch team players from API
  React.useEffect(() => {
    if (showModal) {
      const fetchPlayers = async () => {
        setLoading(true);
        try {
          // Fetch home team players if ID is provided
          if (homeTeamId) {
            const homeResponse = await playersHttpClient.fetchTeamPlayers(
              goChampsApi,
              homeTeamId,
            );
            setHomeTeamPlayers(homeResponse.data.players);
          }

          // Fetch away team players if ID is provided
          if (awayTeamId) {
            const awayResponse = await playersHttpClient.fetchTeamPlayers(
              goChampsApi,
              awayTeamId,
            );
            setAwayTeamPlayers(awayResponse.data.players);
          }
        } catch (error) {
          console.error('Failed to fetch team players:', error);
          // Keep empty arrays on error
        } finally {
          setLoading(false);
        }
      };
      console.log('Fetching players for teams:', { homeTeamId, awayTeamId });
      fetchPlayers();
    }
  }, [showModal, homeTeamId, awayTeamId, goChampsApi]);
  return (
    <Modal
      title={t('basketball.players.modal.title')}
      showModal={showModal}
      onClose={onCloseModal}
      modalCardStyle={{ width: '1024px' }}
    >
      {loading ? (
        <div className="loading-container">
          <div className="loader"></div>
        </div>
      ) : (
        <>
          <div className="tabs is-boxed">
            <ul>
              <li className={activeTab === 'home' ? 'is-active' : ''}>
                <a onClick={() => setActiveTab('home')}>
                  <span>{game_state.home_team.name}</span>
                </a>
              </li>
              <li className={activeTab === 'away' ? 'is-active' : ''}>
                <a onClick={() => setActiveTab('away')}>
                  <span>{game_state.away_team.name}</span>
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
              {selectedView === BASKETBALL_VIEWS.BASIC ? (
                <BasicPlayersTable
                  team={selectedTeam}
                  teamType={activeTab}
                  showAddPlayerRow={showAddPlayerRow}
                  pushEvent={pushEvent}
                  setShowAddPlayerRow={setShowAddPlayerRow}
                  apiPlayers={selectedApiPlayers}
                  currentPlayers={selectedTeam.players}
                  onHighlightPlayer={handleHighlightPlayer}
                  highlightedPlayerId={highlightedPlayerId}
                />
              ) : (
                <MediumPlayersTable
                  team={selectedTeam}
                  teamType={activeTab}
                  showAddPlayerRow={showAddPlayerRow}
                  pushEvent={pushEvent}
                  setShowAddPlayerRow={setShowAddPlayerRow}
                  apiPlayers={selectedApiPlayers}
                  currentPlayers={selectedTeam.players}
                  onHighlightPlayer={handleHighlightPlayer}
                  highlightedPlayerId={highlightedPlayerId}
                />
              )}
            </div>
          </div>
        </>
      )}
    </Modal>
  );
}

export default EditPlayersModal;
