import React, { useEffect } from 'react';
import {
  LiveState,
  LiveStateStates,
  PlayerState,
  TeamState,
  TeamType,
  Selection,
  GameClockState,
  ClockStateStates,
} from '../../types';
import { default as PlayerButton } from './Players/Button';
import { default as CoachButton } from './Coaches/Button';
import { wherePlaying, whereNotPlaying, byPlayer } from './Players/utils';
import { t } from 'i18next';
import { teamPlayersCaptionStyle } from '../../shared/styleHelpers';

interface PlayersControlsProps {
  clockState: GameClockState;
  team: TeamState;
  pushEvent: (event: string, payload: any) => void;
  teamType: TeamType;
  selectEntity: (selection: Selection | null) => void;
  selection: Selection | null;
  liveState: LiveState;
  maxNumberOfPlayerInCourt: number;
  statsOnly?: boolean;
}

function PlayersControls({
  clockState,
  team,
  pushEvent,
  teamType,
  selectEntity,
  selection,
  liveState,
  maxNumberOfPlayerInCourt,
  statsOnly = false,
}: PlayersControlsProps) {
  const playersControlsRef = React.useRef<HTMLDivElement>(null);
  const [selectedPlayers, setSelectedPlayers] = React.useState<PlayerState[]>(
    [],
  );
  const [benchPlayers, setBenchPlayers] = React.useState<PlayerState[]>([]);
  const [playingPlayers, setPlayingPlayers] = React.useState<PlayerState[]>([]);

  const shouldDisplayerWOButton =
    clockState.state === ClockStateStates.NOT_STARTED &&
    playingPlayers.length === 0;

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

    const handleKeydown = (event: KeyboardEvent) => {
      setSelectedPlayers([]);
    };

    document.addEventListener('mousedown', handleClickOutside);
    document.addEventListener('keydown', handleKeydown);

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
      document.removeEventListener('keydown', handleKeydown);
    };
  }, []);

  const handlePlayerClick = (player: PlayerState) => {
    if (selection === null && selectedPlayers.length === 0) {
      setSelectedPlayers([player]);
      selectEntity({
        kind: 'player',
        teamType: teamType,
        player: player,
      });
    } else {
      selectEntity(null);

      if (selectedPlayers.length === 0) {
        setSelectedPlayers([player]);
      } else {
        const firstSelectedPlayer = selectedPlayers[0];
        const sameState =
          (player.state === 'playing' &&
            firstSelectedPlayer.state === 'playing') ||
          (player.state !== 'playing' &&
            firstSelectedPlayer.state !== 'playing');

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
          selectEntity({
            kind: 'player',
            teamType: teamType,
            player: player,
          });
        }
      }
    }
  };

  const handleCoachClick = (coachType: 'head_coach' | 'assistant_coach') => {
    // Find the actual coach from the team
    const coach = team.coaches.find((c) => c.type === coachType);

    if (!coach) {
      // Don't proceed if coach not found
      console.warn(`Coach of type ${coachType} not found in team`);
      return;
    }

    // Clear any player selections
    setSelectedPlayers([]);

    selectEntity({
      kind: 'coach',
      teamType: teamType,
      coach: coach,
    });
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
    selectEntity(null);
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
    selectEntity(null);
  };

  const onClearPlayeringPlayers = () => {
    const playerIds = playingPlayers.map((p) => p.id);

    pushEvent('update-players-state', {
      'team-type': teamType,
      'player-ids': playerIds,
      state: 'bench',
    });

    setSelectedPlayers([]);
    selectEntity(null);
  };

  // Helper functions for button disabled logic
  const hasNoSelectedPlayers = () => selectedPlayers.length === 0;
  const hasDisqualifiedSelectedPlayer = () =>
    selectedPlayers.some((player) => player.state === 'disqualified');
  const isFirstSelectedPlayerPlaying = () =>
    selectedPlayers.length > 0 && selectedPlayers[0].state === 'playing';
  const isFirstSelectedPlayerOnBench = () =>
    selectedPlayers.length > 0 && selectedPlayers[0].state === 'bench';
  const wouldExceedCourtLimit = () =>
    playingPlayers.length + selectedPlayers.length > maxNumberOfPlayerInCourt;
  const hasNoPlayingPlayers = () => playingPlayers.length === 0;

  const isSubInDisabled = () =>
    hasNoSelectedPlayers() ||
    isFirstSelectedPlayerPlaying() ||
    hasDisqualifiedSelectedPlayer() ||
    wouldExceedCourtLimit();

  const isSubOutDisabled = () =>
    hasNoSelectedPlayers() ||
    hasDisqualifiedSelectedPlayer() ||
    isFirstSelectedPlayerOnBench();

  const isClearPlayingPlayersDisabled = () =>
    hasNoPlayingPlayers() || hasDisqualifiedSelectedPlayer();

  const reverseClass =
    teamType === 'away' ? 'is-flex-direction-row-reverse' : '';
  return (
    <div className="players-controls controls" ref={playersControlsRef}>
      <div className="columns is-multiline">
        <div className="on-court column is-12 has-text-centered">
          <span
            className="caption"
            style={teamPlayersCaptionStyle(team.primary_color)}
          >
            {t('basketball.players.onCourt').toUpperCase()}
          </span>

          <div className="columns is-multiline is-centered">
            {!statsOnly && shouldDisplayerWOButton && (
              <div className="column is-12 has-text-centered">
                <button
                  className="button is-warning has-text-weight-bold"
                  disabled={liveState.state === LiveStateStates.NOT_STARTED}
                  onClick={() =>
                    pushEvent('register-team-wo', { 'team-type': teamType })
                  }
                >
                  W.O
                </button>
              </div>
            )}
            {playingPlayers.map((player) => (
              <div key={player.id} className="column is-4 has-text-centered">
                <PlayerButton
                  player={player}
                  onClick={() => handlePlayerClick(player)}
                  disabled={liveState.state === LiveStateStates.NOT_STARTED}
                  isSelected={
                    (selection?.kind === 'player' &&
                      player.id === selection.player.id &&
                      selection.teamType === teamType) ||
                    selectedPlayers.some((p) => p.id === player.id)
                  }
                />
              </div>
            ))}
          </div>
        </div>

        <div className={`coach-controls column is-12 ${reverseClass}`}>
          {!statsOnly && (
            <div>
              <CoachButton
                coach={team.coaches.find((c) => c.type === 'head_coach')}
                coachType="head_coach"
                onClick={() => handleCoachClick('head_coach')}
                isSelected={
                  selection?.kind === 'coach' &&
                  team.coaches.find((c) => c.type === 'head_coach')?.id ===
                    selection.coach.id
                }
                liveState={liveState}
              />
              <CoachButton
                coach={team.coaches.find((c) => c.type === 'assistant_coach')}
                coachType="assistant_coach"
                onClick={() => handleCoachClick('assistant_coach')}
                isSelected={
                  selection?.kind === 'coach' &&
                  team.coaches.find((c) => c.type === 'assistant_coach')?.id ===
                    selection.coach.id
                }
                liveState={liveState}
              />
            </div>
          )}
          {!statsOnly && (
            <div className="substitution-controls">
              <button
                className="button is-warning"
                onClick={onSubIn}
                disabled={isSubInDisabled()}
              >
                ↑
              </button>
              <button
                className="button is-warning"
                onClick={onSubOut}
                disabled={isSubOutDisabled()}
              >
                ↓
              </button>
              <button
                className="button is-warning"
                onClick={onClearPlayeringPlayers}
                disabled={isClearPlayingPlayersDisabled()}
              >
                ↓↓
              </button>
            </div>
          )}
        </div>

        <div className="on-bench column is-12 has-text-centered">
          <span
            className="caption"
            style={teamPlayersCaptionStyle(team.primary_color)}
          >
            {t('basketball.players.onBench').toUpperCase()}
          </span>
          <div className="columns is-multiline is-centered">
            {benchPlayers.map((player) => (
              <div key={player.id} className="column is-4 has-text-centered">
                <PlayerButton
                  player={player}
                  onClick={() => handlePlayerClick(player)}
                  disabled={liveState.state === LiveStateStates.NOT_STARTED}
                  isSelected={
                    (selection?.kind === 'player' &&
                      player.id === selection.player.id &&
                      selection.teamType === teamType) ||
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

export default PlayersControls;
