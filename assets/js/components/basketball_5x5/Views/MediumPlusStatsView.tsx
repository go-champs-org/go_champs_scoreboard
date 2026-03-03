import React from 'react';
import { EventLog, GameState, Selection } from '../../../types';
import { StatsOnlyControls } from '../StatsControls';
import PlayersControls from '../PlayersControls';
import TeamControls from '../TeamControls';
import StatsClockDisplay from '../StatsClockDisplay';
import { MediumPlusStatsTopLevel } from '../TopLevel';

export interface MediumPlusStatsViewProps {
  game_state: GameState;
  recent_events: EventLog[];
  pushEvent: (event: string, payload: any) => void;
  selection: Selection | null;
  setSelection: (selection: Selection | null) => void;
}

function MediumPlusStatsView({
  game_state,
  recent_events,
  pushEvent,
  selection,
  setSelection,
}: MediumPlusStatsViewProps) {
  return (
    <>
      <MediumPlusStatsTopLevel game_state={game_state} pushEvent={pushEvent} />
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
                statsOnly={true}
              />
            </div>
          </div>
        </div>

        <div className="column is-4">
          <div className="columns is-multiline">
            <div className="column is-12">
              <StatsClockDisplay clock_state={game_state.clock_state} />
            </div>
            <div className="column is-12">
              <StatsOnlyControls
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
                statsOnly={true}
              />
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

export default MediumPlusStatsView;
