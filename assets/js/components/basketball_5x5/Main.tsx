import React, { useState } from 'react';
import { GameState, TeamType } from '../../types';
import StatsControls from './StatsControls';
import ClockControls from './ClockControls';
import TopLevel from './TopLevel';
import PlayersControls from './PlayersControls';
import TeamControls, { BasicTeamControls } from './TeamControls';
import EndLiveModal from './EndLiveModal';

export interface LiveReactBase {
  pushEvent: (event: string, payload: any) => void;
  pushEventTo: (event: string, payload: any, selector: string) => void;
  handleEvent: (event: string, callback: (payload: any) => void) => void;
}

export interface PlayerSelection {
  playerId: string;
  teamType: TeamType;
}

interface MainProps extends LiveReactBase {
  game_state: GameState;
}

interface TopControlsProps {
  game_state: GameState;
  pushEvent: (event: string, payload: any) => void;
}

function TopControls({ game_state, pushEvent }: TopControlsProps) {
  if (game_state.view_settings_state.view === 'basketball-basic') {
    return (
      <div className="columns is-multiline">
        <div className="column is-6">
          <BasicTeamControls team={game_state.away_team} teamType="away" />
        </div>
        <div className="column is-6">
          <BasicTeamControls team={game_state.home_team} teamType="home" />
        </div>
      </div>
    );
  }

  return (
    <div className="columns is-multiline">
      <div className="column is-4">
        <TeamControls team={game_state.away_team} teamType="away" />
      </div>

      <div className="column is-4">
        <ClockControls
          clock_state={game_state.clock_state}
          live_state={game_state.live_state}
          pushEvent={pushEvent}
        />
      </div>

      <div className="column is-4">
        <div className="panel">
          <TeamControls team={game_state.home_team} teamType="home" />
        </div>
      </div>
    </div>
  );
}

function Main({ game_state, pushEvent }: MainProps) {
  const [playerSelection, setPlayerSelection] = useState<PlayerSelection>(null);
  const showEndLiveModal = game_state.live_state.state === 'ended';

  return (
    <>
      <TopLevel game_state={game_state} pushEvent={pushEvent} />

      <div className="columns is-multiline">
        <div className="column is-12">
          <TopControls game_state={game_state} pushEvent={pushEvent} />
        </div>

        <div className="column is-4">
          <PlayersControls
            team={game_state.away_team}
            pushEvent={pushEvent}
            teamType="away"
            selectPlayer={setPlayerSelection}
            selectedPlayer={playerSelection}
          />
        </div>

        <div className="column is-4">
          <StatsControls
            playerSelection={playerSelection}
            pushEvent={pushEvent}
            selectPlayer={setPlayerSelection}
            viewSettings={game_state.view_settings_state}
          />
        </div>

        <div className="column is-4">
          <PlayersControls
            team={game_state.home_team}
            pushEvent={pushEvent}
            teamType="home"
            selectPlayer={setPlayerSelection}
            selectedPlayer={playerSelection}
          />
        </div>

        <EndLiveModal showModal={showEndLiveModal} />
      </div>
    </>
  );
}

export default Main;
