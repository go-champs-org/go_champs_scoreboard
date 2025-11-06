import React, { useState } from 'react';
import { EventLog, GameState, TeamType } from '../../types';
import { BasicStatsControls, MediumStatsControls } from './StatsControls';
import TopLevel from './TopLevel';
import PlayersControls from './PlayersControls';
import EndLiveModal from './EndLiveModal';
import MediumTopControls, { BasicTopControls } from './TopControls';
import FoulsModal from './Stats/FoulsModal';
import { FeatureFlag } from '../../shared/FeatureFlags';
import NewPlayersControls from './NewPlayersControls';
import TeamControls from './TeamControls';
import ClockControls from './ClockControls';
import ProtestControls from './ProtestControls';

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
  recent_events: EventLog[];
}

interface ViewProps {
  game_state: GameState;
  recent_events: EventLog[];
  pushEvent: (event: string, payload: any) => void;
}

function BasicView({ game_state, recent_events, pushEvent }: ViewProps) {
  const [playerSelection, setPlayerSelection] = useState<PlayerSelection>(null);

  return (
    <>
      <div className="columns is-multiline">
        <div className="column is-12">
          <BasicTopControls game_state={game_state} pushEvent={pushEvent} />
        </div>

        <div className="column is-4">
          <NewPlayersControls
            team={game_state.home_team}
            pushEvent={pushEvent}
            teamType="home"
            selectPlayer={setPlayerSelection}
            selectedPlayer={playerSelection}
            liveState={game_state.live_state}
          />
        </div>

        <div className="column is-4">
          <BasicStatsControls
            liveState={game_state.live_state}
            playerSelection={playerSelection}
            pushEvent={pushEvent}
            selectPlayer={setPlayerSelection}
            gameState={game_state}
          />
        </div>

        <div className="column is-4">
          <NewPlayersControls
            team={game_state.away_team}
            pushEvent={pushEvent}
            teamType="away"
            selectPlayer={setPlayerSelection}
            selectedPlayer={playerSelection}
            liveState={game_state.live_state}
          />
        </div>
      </div>
    </>
  );
}

function MediumView({ game_state, recent_events, pushEvent }: ViewProps) {
  const [playerSelection, setPlayerSelection] = useState<PlayerSelection>(null);
  const [showFoulsModal, setShowFoulsModal] = useState(false);

  return (
    <>
      <div className="columns is-multiline">
        <div className="column is-4">
          <div className="columns is-multiline">
            <div className="column is-12">
              <TeamControls team={game_state.home_team} teamType="home" />
            </div>
            <div className="column is-12">
              <NewPlayersControls
                pushEvent={pushEvent}
                selectPlayer={setPlayerSelection}
                selectedPlayer={playerSelection}
                team={game_state.home_team}
                teamType="home"
                liveState={game_state.live_state}
              />
            </div>
          </div>
        </div>

        <div className="column is-4">
          <div className="columns is-multiline">
            <div className="column is-12">
              {game_state.clock_state.state === 'finished' ? (
                <ProtestControls
                  game_state={game_state}
                  pushEvent={pushEvent}
                />
              ) : (
                <ClockControls
                  away_team={game_state.away_team}
                  clock_state={game_state.clock_state}
                  home_team={game_state.home_team}
                  live_state={game_state.live_state}
                  pushEvent={pushEvent}
                />
              )}
            </div>
            <div className="column is-12">
              <MediumStatsControls
                liveState={game_state.live_state}
                playerSelection={playerSelection}
                pushEvent={pushEvent}
                selectPlayer={setPlayerSelection}
                gameState={game_state}
                onShowFoulsModal={() => setShowFoulsModal(true)}
              />
            </div>
          </div>
        </div>

        <div className="column is-4">
          <div className="columns is-multiline">
            <div className="column is-12">
              <TeamControls team={game_state.away_team} teamType="away" />
            </div>
            <div className="column is-12">
              <NewPlayersControls
                pushEvent={pushEvent}
                selectPlayer={setPlayerSelection}
                selectedPlayer={playerSelection}
                team={game_state.away_team}
                teamType="away"
                liveState={game_state.live_state}
              />
            </div>
          </div>
        </div>
      </div>
      <FoulsModal
        gameState={game_state}
        showModal={showFoulsModal}
        onCloseModal={() => setShowFoulsModal(false)}
        pushEvent={pushEvent}
      />
    </>
  );
}

function Main({ game_state, recent_events, pushEvent }: MainProps) {
  const showEndLiveModal = game_state.live_state.state === 'ended';

  return (
    <>
      <TopLevel game_state={game_state} pushEvent={pushEvent} />

      {game_state.view_settings_state.view === 'basketball-basic' ? (
        <BasicView
          game_state={game_state}
          recent_events={recent_events}
          pushEvent={pushEvent}
        />
      ) : (
        <MediumView
          game_state={game_state}
          recent_events={recent_events}
          pushEvent={pushEvent}
        />
      )}

      <EndLiveModal showModal={showEndLiveModal} />
    </>
  );
}

export default Main;
