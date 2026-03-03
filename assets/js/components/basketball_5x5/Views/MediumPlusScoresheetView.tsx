import React from 'react';
import { EventLog, GameState, Selection } from '../../../types';
import { ScoresheetStatsControls } from '../StatsControls';
import PlayersControls from '../PlayersControls';
import TeamControls from '../TeamControls';
import ClockControls from '../ClockControls';
import ProtestControls from '../ProtestControls';
import { MediumPlusTopLevel } from '../TopLevel';

export interface MediumPlusScoresheetViewProps {
  game_state: GameState;
  recent_events: EventLog[];
  pushEvent: (event: string, payload: any) => void;
  selection: Selection | null;
  setSelection: (selection: Selection | null) => void;
}

function MediumPlusScoresheetView({
  game_state,
  recent_events,
  pushEvent,
  selection,
  setSelection,
}: MediumPlusScoresheetViewProps) {
  return (
    <>
      <MediumPlusTopLevel game_state={game_state} pushEvent={pushEvent} />
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
                clockState={game_state.clock_state}
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
              <ScoresheetStatsControls
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
                clockState={game_state.clock_state}
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

export default MediumPlusScoresheetView;
