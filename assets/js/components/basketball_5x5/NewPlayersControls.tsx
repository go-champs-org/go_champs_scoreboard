import React, { useEffect } from 'react';
import { PlayerState, TeamState, TeamType } from '../../types';
import { PlayerSelection } from './Main';
import { default as PlayerButton } from './Players/Button';
import { wherePlaying, whereNotPlaying, byPlayer } from './Players/utils';

interface NewPlayersControlsProps {
  team: TeamState;
  pushEvent: (event: string, payload: any) => void;
  teamType: TeamType;
  selectPlayer: (playerSelection: PlayerSelection | null) => void;
  selectedPlayer: PlayerSelection | null;
}

function NewPlayersControls({
  team,
  pushEvent,
  teamType,
  selectPlayer,
  selectedPlayer,
}: NewPlayersControlsProps) {
  const playersControlsRef = React.useRef<HTMLDivElement>(null);
  const [selectedPlayers, setSelectedPlayers] = React.useState<PlayerState[]>(
    [],
  );
  const [benchPlayers, setBenchPlayers] = React.useState<PlayerState[]>([]);
  const [playingPlayers, setPlayingPlayers] = React.useState<PlayerState[]>([]);

  useEffect(() => {
    const bench = team.players.filter(whereNotPlaying).sort(byPlayer);
    const playing = team.players.filter(wherePlaying).sort(byPlayer);

    setBenchPlayers(bench);
    setPlayingPlayers(playing);
  }, [team.players]);
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        playersControlsRef.current &&
        !playersControlsRef.current.contains(event.target as Node)
      ) {
        setSelectedPlayers([]);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  const handlePlayerClick = (player: PlayerState) => {
    if (selectedPlayer === null && selectedPlayers.length === 0) {
      selectPlayer({
        playerId: player.id,
        teamType: teamType,
      });
      setSelectedPlayers([player]);
    } else {
      selectPlayer(null);

      if (selectedPlayers.length === 0) {
        setSelectedPlayers([player]);
      } else {
        const firstSelectedPlayer = selectedPlayers[0];
        const sameState = player.state === firstSelectedPlayer.state;

        if (sameState) {
          const isAlreadySelected = selectedPlayers.some(
            (p) => p.id === player.id,
          );

          if (isAlreadySelected) {
            setSelectedPlayers(
              selectedPlayers.filter((p) => p.id !== player.id),
            );
          } else {
            setSelectedPlayers([...selectedPlayers, player]);
          }
        } else {
          setSelectedPlayers([player]);
          selectPlayer({
            playerId: player.id,
            teamType: teamType,
          });
        }
      }
    }
  };

  const onSubIn = () => {
    if (selectedPlayers.length === 0) return;

    const playerIds = selectedPlayers.map((p) => p.id);

    pushEvent('update-players-state', {
      'team-type': teamType,
      'player-ids': playerIds,
      state: 'playing',
    });

    setSelectedPlayers([]);
    selectPlayer(null);
  };

  const onSubOut = () => {
    if (selectedPlayers.length === 0) return;

    const playerIds = selectedPlayers.map((p) => p.id);

    pushEvent('update-players-state', {
      'team-type': teamType,
      'player-ids': playerIds,
      state: 'bench',
    });

    setSelectedPlayers([]);
    selectPlayer(null);
  };

  const onClearPlayeringPlayers = () => {
    const playerIds = playingPlayers.map((p) => p.id);

    pushEvent('update-players-state', {
      'team-type': teamType,
      'player-ids': playerIds,
      state: 'bench',
    });

    setSelectedPlayers([]);
    selectPlayer(null);
  };
  const reverseClass =
    teamType === 'away' ? 'is-flex-direction-row-reverse' : '';

  return (
    <div className="players-controls controls" ref={playersControlsRef}>
      <div className="columns is-multiline">
        <div className="on-court column is-12 has-text-centered">
          <span className="caption">On Court</span>
          <div className="columns is-multiline is-centered">
            {playingPlayers.map((player) => (
              <div key={player.id} className="column is-4 has-text-centered">
                <PlayerButton
                  player={player}
                  onClick={() => handlePlayerClick(player)}
                  isSelected={
                    (player.id === selectedPlayer?.playerId &&
                      selectedPlayer?.teamType === teamType) ||
                    selectedPlayers.some((p) => p.id === player.id)
                  }
                />
              </div>
            ))}
          </div>
        </div>

        <div className={`coach-controls column is-12 ${reverseClass}`}>
          <div>
            <button className="coach-button button">ASS. TEC</button>
            <button className="coach-button button">TÉCNICO</button>
          </div>
          <div className="substitution-controls">
            <button
              className="button is-warning"
              onClick={onSubIn}
              disabled={
                selectedPlayers.length === 0 ||
                selectedPlayers[0].state === 'playing'
              }
            >
              ↑
            </button>
            <button
              className="button is-warning"
              onClick={onSubOut}
              disabled={
                selectedPlayers.length === 0 ||
                selectedPlayers[0].state === 'bench'
              }
            >
              ↓
            </button>
            <button
              className="button is-warning"
              onClick={onClearPlayeringPlayers}
              disabled={playingPlayers.length === 0}
            >
              ↓↓
            </button>
          </div>
        </div>

        <div className="on-bench column is-12 has-text-centered">
          <span className="caption">On Bench</span>
          <div className="columns is-multiline is-centered">
            {benchPlayers.map((player) => (
              <div key={player.id} className="column is-4 has-text-centered">
                <PlayerButton
                  player={player}
                  onClick={() => handlePlayerClick(player)}
                  isSelected={
                    (player.id === selectedPlayer?.playerId &&
                      selectedPlayer?.teamType === teamType) ||
                    selectedPlayers.some((p) => p.id === player.id)
                  }
                />
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

export default NewPlayersControls;
