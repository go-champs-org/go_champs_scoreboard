import React from 'react';

import { TeamState, TeamType } from '../../types';

interface TeamControlsProps {
  team: TeamState;
  teamType: TeamType;
}

function TeamControls({ team, teamType }: TeamControlsProps) {
  const reverseClass =
    teamType === 'home' ? 'is-flex-direction-row-reverse' : '';
  const teamNameClass = teamType === 'home' ? 'is-justify-content-right' : '';
  return (
    <div className="controls team-controls">
      <div className={`columns is-multiline ${reverseClass}`}>
        <div
          className={`column is-9 is-flex is-align-items-center ${teamNameClass}`}
        >
          <p className="title is-4">{team.name}</p>
        </div>
        <div className="column is-3">
          <p className="chip-label title is-4">
            {team.total_player_stats['points'] || 0}
          </p>
        </div>
        <div className="column is-12">
          <div className="columns">
            <div className="column is-4">
              <div className="team-stat">
                <p className="stat-label">REBs:</p>
                <p className="stat-value">
                  {team.total_player_stats['rebounds'] || 0}
                </p>
              </div>

              <div className="team-stat">
                <p className="stat-label">O REBs:</p>
                <p className="stat-value">
                  {team.total_player_stats['rebounds_offensive'] || 0}
                </p>
              </div>

              <div className="team-stat">
                <p className="stat-label">D REBs:</p>
                <p className="stat-value">
                  {team.total_player_stats['rebounds_defensive'] || 0}
                </p>
              </div>
            </div>

            <div className="column is-4">
              <div className="team-stat">
                <p className="stat-label">ASTs:</p>
                <p className="stat-value">
                  {team.total_player_stats['assists'] || 0}
                </p>
              </div>

              <div className="team-stat">
                <p className="stat-label">STLs:</p>
                <p className="stat-value">
                  {team.total_player_stats['steals'] || 0}
                </p>
              </div>

              <div className="team-stat">
                <p className="stat-label">BLKs:</p>
                <p className="stat-value">
                  {team.total_player_stats['blocks'] || 0}
                </p>
              </div>
            </div>

            <div className="column is-4">
              <div className="team-stat">
                <p className="stat-label">TOs:</p>
                <p className="stat-value">
                  {team.total_player_stats['turnovers'] || 0}
                </p>
              </div>

              <div className="team-stat">
                <p className="stat-label">PFs:</p>
                <p className="stat-value">
                  {team.total_player_stats['fouls_personal'] || 0}
                </p>
              </div>

              <div className="team-stat">
                <p className="stat-label">TFs:</p>
                <p className="stat-value">
                  {team.total_player_stats['fouls_technical'] || 0}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default TeamControls;
