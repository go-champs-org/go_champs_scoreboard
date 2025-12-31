import React from 'react';
import { EventLog, GameState } from '../../../types';
import TeamName from './TeamName';

function RegisterTeamWOPayload({
  eventLog,
  gameState,
}: {
  eventLog: EventLog;
  gameState: GameState;
}) {
  return (
    <>
      <TeamName
        gameState={gameState}
        teamType={eventLog.payload ? eventLog.payload['team-type'] : undefined}
      />
    </>
  );
}

export default RegisterTeamWOPayload;
