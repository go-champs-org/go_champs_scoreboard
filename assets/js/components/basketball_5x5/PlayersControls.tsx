import React from 'react';
import { useTranslation } from 'react-i18next';

import { PlayerState, TeamState, TeamType } from '../../types';
import { PlayerSelection } from './Main';

interface PlayingPlayersProps {
  players: PlayerState[];
  teamType: TeamType;
  selectPlayer: (playerSelection: PlayerSelection) => void;
  selectedPlayer?: PlayerSelection;
  onSubstituteClick: (playerId: string) => void;
}

function renderPlayerButtonText(player: PlayerState) {
  if (!player.number) {
    return `${player.name}`;
  }

  return `${player.number} - ${player.name}`;
}

function PlayingPlayers({
  players,
  teamType,
  selectPlayer,
  selectedPlayer,
  onSubstituteClick,
}: PlayingPlayersProps) {
  const { t } = useTranslation();
  const subButtonDisabled =
    selectedPlayer === null || selectedPlayer?.teamType !== teamType;
  return (
    <div className="controls">
      <div className="columns is-multiline">
        {players.map((player) => (
          <div key={player.id} className="column is-12">
            <button
              className={`button is-fullwidth ${
                player.id === selectedPlayer?.playerId ? 'is-dark' : ''
              }`}
              onClick={() =>
                selectPlayer({ playerId: player.id, teamType: teamType })
              }
            >
              {renderPlayerButtonText(player)}
            </button>
          </div>
        ))}
        <div className="column is-12"></div>
        <div className="column is-12">
          <button
            className="button is-warning is-fullwidth"
            onClick={onSubstituteClick}
            disabled={subButtonDisabled}
          >
            {t('basketball.players.controls.substitute')}
          </button>
        </div>
      </div>
    </div>
  );
}

interface BenchPlayersProps {
  players: PlayerState[];
  selectedPlayer: PlayerSelection;
  teamType: TeamType;
  onPlayerClick: (playerId: string) => void;
  onCancelClick: () => void;
}

function BenchPlayers({
  players,
  selectedPlayer,
  teamType,
  onPlayerClick,
  onCancelClick,
}: BenchPlayersProps) {
  const { t } = useTranslation();
  const playerButtonDisabled =
    selectedPlayer === null || selectedPlayer.teamType !== teamType;
  return (
    <div className="controls">
      <div className="columns is-multiline">
        {players.map((player) => (
          <div key={player.id} className="column is-12">
            <button
              disabled={playerButtonDisabled}
              className="button is-fullwidth"
              onClick={() => onPlayerClick(player.id)}
            >
              {renderPlayerButtonText(player)}
            </button>
          </div>
        ))}
        <div className="column is-12"></div>
        <div className="column is-12">
          <button
            className="button is-warning is-fullwidth"
            onClick={onCancelClick}
          >
            {t('basketball.players.controls.cancel')}
          </button>
        </div>
      </div>
    </div>
  );
}

interface NotStartingPlayersProps {
  players: PlayerState[];
  teamType: TeamType;
  onPlayerClick: (playerSelection: PlayerSelection) => void;
}

function NotStartingPlayers({
  players,
  teamType,
  onPlayerClick,
}: NotStartingPlayersProps) {
  const { t } = useTranslation();
  return (
    <div className="controls">
      <div className="columns is-multiline">
        <div className="column is-12 has-text-centered">
          <span className="title is-3 has-text-warning">
            {t('basketball.players.instructions.selectStarting')}
          </span>
        </div>
        {players.map((player) => (
          <div key={player.id} className="column is-12">
            <button
              className="button is-fullwidth"
              onClick={() =>
                onPlayerClick({ playerId: player.id, teamType: teamType })
              }
            >
              {renderPlayerButtonText(player)}
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}

interface PlayersControlsProps {
  team: TeamState;
  pushEvent: (event: string, payload: any) => void;
  teamType: TeamType;
  selectPlayer: (playerSelection: PlayerSelection | null) => void;
  selectedPlayer: PlayerSelection;
}

type PlayerView = 'playing' | 'bench' | 'not_started';

function PlayersControls({
  team,
  pushEvent,
  teamType,
  selectPlayer,
  selectedPlayer,
}: PlayersControlsProps) {
  const playingPlayers = team.players.filter(
    (player) => player.state === 'playing',
  );
  const benchPlayers = team.players.filter(
    (player) => player.state !== 'playing' && player.state !== 'not_available',
  );
  const initialView = playingPlayers.length < 5 ? 'not_started' : 'playing';
  const [playerView, setPlayerView] = React.useState<PlayerView>(initialView);
  React.useEffect(() => {
    setPlayerView(initialView);
  }, [initialView]);
  const onSubstitute = (playerId: string) => {
    pushEvent('substitute-player', {
      ['team-type']: teamType,
      ['playing-player-id']: selectedPlayer.playerId,
      ['bench-player-id']: playerId,
    });
    setPlayerView('playing');
    selectPlayer(null);
  };
  const onPlayerStartUp = (selectPlayer: PlayerSelection) => {
    pushEvent('substitute-player', {
      ['team-type']: selectPlayer.teamType,
      ['playing-player-id']: null,
      ['bench-player-id']: selectPlayer.playerId,
    });
  };

  return (
    <>
      {playerView === 'playing' && (
        <PlayingPlayers
          players={playingPlayers}
          selectPlayer={selectPlayer}
          selectedPlayer={selectedPlayer}
          teamType={teamType}
          onSubstituteClick={() => setPlayerView('bench')}
        />
      )}
      {playerView === 'bench' && (
        <BenchPlayers
          players={benchPlayers}
          selectedPlayer={selectedPlayer}
          teamType={teamType}
          onCancelClick={() => setPlayerView('playing')}
          onPlayerClick={onSubstitute}
        />
      )}
      {playerView === 'not_started' && (
        <NotStartingPlayers
          teamType={teamType}
          players={benchPlayers}
          onPlayerClick={onPlayerStartUp}
        />
      )}
    </>
  );
}

export default PlayersControls;
