import React from 'react';
import { EventLog, GameState, Selection } from '../../../types';
import { BasicStatsControls } from '../StatsControls';
import { BasicTopControls } from '../TopControls';
import PlayersControls from '../PlayersControls';
import { BasicTopLevel } from '../TopLevel';

export interface BasicViewProps {
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
}: BasicViewProps) {
  return (
    <>
      <BasicTopLevel game_state={game_state} pushEvent={pushEvent} />

      <div className="columns is-multiline">
        <div className="column is-12">
          <BasicTopControls game_state={game_state} pushEvent={pushEvent} />
        </div>

        <div className="column is-4">
          <PlayersControls
            clockState={game_state.clock_state}
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
            clockState={game_state.clock_state}
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

export default BasicView;
