import React, { useState } from 'react';
import { EventLog, GameState, TeamType, Selection } from '../../types';
import { BasicStatsControls, MediumStatsControls } from './StatsControls';
import TopLevel from './TopLevel';
import LiveEndedModal from './LiveEndedModal';
import { BasicTopControls } from './TopControls';
import PlayersControls from './PlayersControls';
import TeamControls from './TeamControls';
import ClockControls from './ClockControls';
import ProtestControls from './ProtestControls';

export interface LiveReactBase {
  pushEvent: (event: string, payload: any) => void;
  pushEventTo: (event: string, payload: any, selector: string) => void;
  handleEvent: (event: string, callback: (payload: any) => void) => void;
}

interface MainProps extends LiveReactBase {
  game_state: GameState;
  recent_events: EventLog[];
}

interface ViewProps {
  game_state: GameState;
  recent_events: EventLog[];
  pushEvent: (event: string, payload: any) => void;
  selection: Selection | null;
  setSelection: (selection: Selection | null) => void;
}

function BasicView({
  game_state,
  recent_events,
  pushEvent,
  selection,
  setSelection,
}: ViewProps) {
  return (
    <>
      <div className="columns is-multiline">
        <div className="column is-12">
          <BasicTopControls game_state={game_state} pushEvent={pushEvent} />
        </div>

        <div className="column is-4">
          <PlayersControls
            team={game_state.home_team}
            pushEvent={pushEvent}
            teamType="home"
            selectEntity={setSelection}
            selection={selection}
            liveState={game_state.live_state}
            maxNumberOfPlayerInCourt={5}
          />
        </div>

        <div className="column is-4">
          <BasicStatsControls
            liveState={game_state.live_state}
            selection={selection}
            pushEvent={pushEvent}
            selectEntity={setSelection}
          />
        </div>

        <div className="column is-4">
          <PlayersControls
            team={game_state.away_team}
            pushEvent={pushEvent}
            teamType="away"
            selectEntity={setSelection}
            selection={selection}
            liveState={game_state.live_state}
            maxNumberOfPlayerInCourt={5}
          />
        </div>
      </div>
    </>
  );
}

function MediumView({
  game_state,
  recent_events,
  pushEvent,
  selection,
  setSelection,
}: ViewProps) {
  return (
    <>
      <div className="columns is-multiline">
        <div className="column is-4">
          <div className="columns is-multiline">
            <div className="column is-12">
              <TeamControls
                team={game_state.home_team}
                teamType="home"
                clock_state={game_state.clock_state}
              />
            </div>
            <div className="column is-12">
              <PlayersControls
                pushEvent={pushEvent}
                selectEntity={setSelection}
                selection={selection}
                team={game_state.home_team}
                teamType="home"
                liveState={game_state.live_state}
                maxNumberOfPlayerInCourt={5}
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
                selection={selection}
                pushEvent={pushEvent}
                selectEntity={setSelection}
              />
            </div>
          </div>
        </div>

        <div className="column is-4">
          <div className="columns is-multiline">
            <div className="column is-12">
              <TeamControls
                team={game_state.away_team}
                teamType="away"
                clock_state={game_state.clock_state}
              />
            </div>
            <div className="column is-12">
              <PlayersControls
                pushEvent={pushEvent}
                selectEntity={setSelection}
                selection={selection}
                team={game_state.away_team}
                teamType="away"
                liveState={game_state.live_state}
                maxNumberOfPlayerInCourt={5}
              />
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

function Main({ game_state, recent_events, pushEvent }: MainProps) {
  const showLiveEndedModal = game_state.live_state.state === 'ended';
  const [selection, setSelection] = useState<Selection | null>(null);

  return (
    <>
      <TopLevel game_state={game_state} pushEvent={pushEvent} />

      {game_state.view_settings_state.view === 'basketball-basic' ? (
        <BasicView
          game_state={game_state}
          recent_events={recent_events}
          pushEvent={pushEvent}
          selection={selection}
          setSelection={setSelection}
        />
      ) : (
        <MediumView
          game_state={game_state}
          recent_events={recent_events}
          pushEvent={pushEvent}
          selection={selection}
          setSelection={setSelection}
        />
      )}

      <LiveEndedModal showModal={showLiveEndedModal} />
    </>
  );
}

export default Main;
