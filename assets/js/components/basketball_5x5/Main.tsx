import React, { useState } from 'react';
import { EventLog, GameState, Selection } from '../../types';
import LiveEndedModal from './LiveEndedModal';
import { BASKETBALL_VIEWS } from './constants';
import { useSelectedView } from '../../shared/ViewSettingsContext';
import MediumView from './Views/MediumView';
import MediumPlusView from './Views/MediumPlusView';
import BasicView from './Views/BasicView';

export interface LiveReactBase {
  pushEvent: (event: string, payload: any) => void;
  pushEventTo: (event: string, payload: any, selector: string) => void;
  handleEvent: (event: string, callback: (payload: any) => void) => void;
}

interface MainProps extends LiveReactBase {
  game_state: GameState;
  recent_events: EventLog[];
}

function Main({ game_state, recent_events, pushEvent }: MainProps) {
  const showLiveEndedModal = game_state.live_state.state === 'ended';
  const [selection, setSelection] = useState<Selection | null>(null);
  const selectedView = useSelectedView();

  return (
    <>
      {selectedView === BASKETBALL_VIEWS.MEDIUM && (
        <MediumView
          game_state={game_state}
          recent_events={recent_events}
          pushEvent={pushEvent}
          selection={selection}
          setSelection={setSelection}
        />
      )}

      {selectedView === BASKETBALL_VIEWS.MEDIUM_PLUS && (
        <MediumPlusView
          game_state={game_state}
          recent_events={recent_events}
          pushEvent={pushEvent}
          selection={selection}
          setSelection={setSelection}
        />
      )}

      {selectedView === BASKETBALL_VIEWS.BASIC && (
        <BasicView
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
