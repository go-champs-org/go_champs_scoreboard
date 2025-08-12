import React from 'react';
import { useTranslation } from '../../hooks/useTranslation';

import { TeamState, TeamType } from '../../types';

interface TeamControlsProps {
  team: TeamState;
  teamType: TeamType;
}

export function BasicTeamControls({ team, teamType }: TeamControlsProps) {
  const { t } = useTranslation();
  const reverseClass =
    teamType === 'home' ? 'is-flex-direction-row-reverse' : '';
  const teamNameClass = teamType === 'home' ? 'is-justify-content-right' : '';
  return (
    <div className="controls team-controls">
      <div className={`columns is-multiline ${reverseClass}`}>
        <div
          className={`column is-7 is-flex is-align-items-center ${teamNameClass}`}
        >
          <p className="title is-4">{team.name}</p>
        </div>
        <div className="column is-2">
          {team.logo_url && (
            <img
              src={team.logo_url}
              alt={`${team.name} logo`}
              className="team-logo"
            />
          )}
        </div>
        <div className="column is-3">
          <p className="chip-label title is-4">
            {team.total_player_stats['points'] || 0}
          </p>
        </div>
        <div className="column is-12">
          <div className="columns">
            <div className="column is-3">
              <div className="team-stat">
                <p className="stat-label">
                  {t('basketball.stats.abbreviations.rebounds')}:
                </p>
                <p className="stat-value">
                  {team.total_player_stats['rebounds'] || 0}
                </p>
              </div>
            </div>

            <div className="column is-3">
              <div className="team-stat">
                <p className="stat-label">
                  {t('basketball.stats.abbreviations.assists')}:
                </p>
                <p className="stat-value">
                  {team.total_player_stats['assists'] || 0}
                </p>
              </div>
            </div>
            <div className="column is-3">
              <div className="team-stat">
                <p className="stat-label">
                  {t('basketball.stats.abbreviations.steals')}:
                </p>
                <p className="stat-value">
                  {team.total_player_stats['steals'] || 0}
                </p>
              </div>
            </div>

            <div className="column is-3">
              <div className="team-stat">
                <p className="stat-label">
                  {t('basketball.stats.abbreviations.blocks')}:
                </p>
                <p className="stat-value">
                  {team.total_player_stats['blocks'] || 0}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function TeamControls({ team, teamType }: TeamControlsProps) {
  const { t } = useTranslation();
  const reverseClass =
    teamType === 'home' ? 'is-flex-direction-row-reverse' : '';
  const teamNameClass = teamType === 'home' ? 'is-justify-content-right' : '';
  return (
    <div className="controls team-controls">
      <div className={`columns is-multiline ${reverseClass}`}>
        <div
          className={`column is-7 is-flex is-align-items-center ${teamNameClass}`}
        >
          <p className="title is-4">{team.name}</p>
        </div>
        <div className="column is-2 logo-container">
          {team.logo_url && (
            <img
              src={team.logo_url}
              alt={`${team.name} logo`}
              className="logo"
            />
          )}
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
                <p className="stat-label">
                  {t('basketball.stats.abbreviations.rebounds')}:
                </p>
                <p className="stat-value">
                  {team.total_player_stats['rebounds'] || 0}
                </p>
              </div>

              <div className="team-stat">
                <p className="stat-label">
                  {t('basketball.stats.abbreviations.offensiveRebounds')}:
                </p>
                <p className="stat-value">
                  {team.total_player_stats['rebounds_offensive'] || 0}
                </p>
              </div>

              <div className="team-stat">
                <p className="stat-label">
                  {t('basketball.stats.abbreviations.defensiveRebounds')}:
                </p>
                <p className="stat-value">
                  {team.total_player_stats['rebounds_defensive'] || 0}
                </p>
              </div>
            </div>

            <div className="column is-4">
              <div className="team-stat">
                <p className="stat-label">
                  {t('basketball.stats.abbreviations.assists')}:
                </p>
                <p className="stat-value">
                  {team.total_player_stats['assists'] || 0}
                </p>
              </div>

              <div className="team-stat">
                <p className="stat-label">
                  {t('basketball.stats.abbreviations.steals')}:
                </p>
                <p className="stat-value">
                  {team.total_player_stats['steals'] || 0}
                </p>
              </div>

              <div className="team-stat">
                <p className="stat-label">
                  {t('basketball.stats.abbreviations.blocks')}:
                </p>
                <p className="stat-value">
                  {team.total_player_stats['blocks'] || 0}
                </p>
              </div>
            </div>

            <div className="column is-4">
              <div className="team-stat">
                <p className="stat-label">
                  {t('basketball.stats.abbreviations.turnovers')}:
                </p>
                <p className="stat-value">
                  {team.total_player_stats['turnovers'] || 0}
                </p>
              </div>

              <div className="team-stat">
                <p className="stat-label">
                  {t('basketball.stats.abbreviations.personalFouls')}:
                </p>
                <p className="stat-value">
                  {team.total_player_stats['fouls_personal'] || 0}
                </p>
              </div>

              <div className="team-stat">
                <p className="stat-label">
                  {t('basketball.stats.abbreviations.technicalFouls')}:
                </p>
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
