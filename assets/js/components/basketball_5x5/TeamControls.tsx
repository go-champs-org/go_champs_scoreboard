import React from 'react';
import { useTranslation } from '../../hooks/useTranslation';

import { GameClockState, TeamState, TeamType } from '../../types';

interface TeamControlsProps {
  team: TeamState;
  teamType: TeamType;
  clock_state: GameClockState;
}

// Calculate timeout stats from period_stats
const calculateTimeoutStats = (
  periodStats: Record<string, any> = {},
  currentPeriod: number,
) => {
  // First half (periods 1, 2) - can use 2 timeouts
  const firstHalfUsed =
    (periodStats['1']?.timeouts || 0) + (periodStats['2']?.timeouts || 0);
  const firstHalfRemaining = Math.max(0, 2 - firstHalfUsed);

  // Second half (periods 3, 4) - can use 3 timeouts
  const secondHalfUsed =
    (periodStats['3']?.timeouts || 0) + (periodStats['4']?.timeouts || 0);
  const secondHalfRemaining = Math.max(0, 3 - secondHalfUsed);

  // Extra time (period 5 and beyond) - calculate used
  let extraUsed = 0;
  for (let period = 5; period <= 10; period++) {
    extraUsed += periodStats[period.toString()]?.timeouts || 0;
  }

  // For extraRemaining: if current period has 0 timeouts, set to 1, otherwise 0
  const currentPeriodTimeouts =
    periodStats[currentPeriod.toString()]?.timeouts || 0;
  const extraRemaining =
    currentPeriod >= 5 && currentPeriodTimeouts === 0 ? 1 : 0;

  return {
    firstHalf: { used: firstHalfUsed, remaining: firstHalfRemaining },
    secondHalf: { used: secondHalfUsed, remaining: secondHalfRemaining },
    extra: { used: extraUsed, remaining: extraRemaining },
  };
};

// Calculate current quarter stats from period_stats
const calculateCurrentQuarterStats = (
  periodStats: Record<string, any> = {},
  currentPeriod: number,
) => {
  const currentPeriodString = currentPeriod.toString();

  const currentQuarterFouls = periodStats[currentPeriodString]?.fouls || 0;
  const currentQuarterPoints = periodStats[currentPeriodString]?.points || 0;

  return { fouls: currentQuarterFouls, points: currentQuarterPoints };
};

function QuarterStats({
  team,
  clock_state,
}: {
  team: TeamState;
  clock_state: GameClockState;
}) {
  const { t } = useTranslation();

  const timeoutStats = calculateTimeoutStats(
    team.period_stats,
    clock_state.period,
  );
  const currentQuarterStats = calculateCurrentQuarterStats(
    team.period_stats,
    clock_state.period,
  );

  return (
    <div className="quarter-stats-container">
      <div className="columns is-mobile">
        <div className="column is-8">
          <div className="timeout-section">
            <div className="timeout-item">
              <div className="team-stat">
                <p className="stat-label">
                  {t('basketball.quarterStats.firstHalfTimeouts')}:
                </p>
                <div className="stat-timeouts">
                  <span className="timeout-badge consumed">
                    {t('basketball.quarterStats.used')}:{' '}
                    {timeoutStats.firstHalf.used}
                  </span>
                  <span className="timeout-badge remaining">
                    {t('basketball.quarterStats.remaining')}:{' '}
                    {timeoutStats.firstHalf.remaining}
                  </span>
                </div>
              </div>
            </div>
            <div className="timeout-item">
              <div className="team-stat">
                <p className="stat-label">
                  {t('basketball.quarterStats.secondHalfTimeouts')}:
                </p>
                <div className="stat-timeouts">
                  <span className="timeout-badge consumed">
                    {t('basketball.quarterStats.used')}:{' '}
                    {timeoutStats.secondHalf.used}
                  </span>
                  <span className="timeout-badge remaining">
                    {t('basketball.quarterStats.remaining')}:{' '}
                    {timeoutStats.secondHalf.remaining}
                  </span>
                </div>
              </div>
            </div>
            <div className="timeout-item">
              <div className="team-stat">
                <p className="stat-label">
                  {t('basketball.quarterStats.extraTimeouts')}:
                </p>
                <div className="stat-timeouts">
                  {timeoutStats.extra.used > 0 && (
                    <span className="timeout-badge consumed">
                      {t('basketball.quarterStats.used')}:{' '}
                      {timeoutStats.extra.used}
                    </span>
                  )}
                  <span className="timeout-badge remaining">
                    {t('basketball.quarterStats.remaining')}:{' '}
                    {timeoutStats.extra.remaining}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="column is-4">
          <div className="quarter-stats-section">
            <div className="team-stat quarter-stat">
              <p className="stat-label">
                {t('basketball.quarterStats.quarterFouls')}:
              </p>
              <p className="stat-value quarter-stat-value">
                {currentQuarterStats.fouls}
              </p>
            </div>
            <div className="team-stat quarter-stat">
              <p className="stat-label">
                {t('basketball.quarterStats.quarterPoints')}:
              </p>
              <p className="stat-value quarter-stat-value">
                {currentQuarterStats.points}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function TotalStatsValues({ team }: { team: TeamState }) {
  const { t } = useTranslation();

  return (
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
          <p className="stat-value">{team.total_player_stats['steals'] || 0}</p>
        </div>

        <div className="team-stat">
          <p className="stat-label">
            {t('basketball.stats.abbreviations.blocks')}:
          </p>
          <p className="stat-value">{team.total_player_stats['blocks'] || 0}</p>
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
  );
}

function TeamStats({
  team,
  clock_state,
}: {
  team: TeamState;
  clock_state: GameClockState;
}) {
  const [showTotals, setShowTotals] = React.useState(false);
  const [isAnimating, setIsAnimating] = React.useState(false);

  const handleToggle = () => {
    if (isAnimating) return;

    setIsAnimating(true);
    setTimeout(() => {
      setShowTotals(!showTotals);
      setIsAnimating(false);
    }, 150); // Half of the animation duration
  };

  return (
    <div
      className={`team-stats ${isAnimating ? 'is-sliding' : ''}`}
      onClick={handleToggle}
    >
      {showTotals ? (
        <TotalStatsValues team={team} />
      ) : (
        <QuarterStats team={team} clock_state={clock_state} />
      )}
    </div>
  );
}

export function BasicTeamControls({ team, teamType }: TeamControlsProps) {
  const { t } = useTranslation();
  const reverseClass =
    teamType === 'away' ? 'is-flex-direction-row-reverse' : '';
  const teamNameClass = teamType === 'away' ? 'is-justify-content-right' : '';
  return (
    <div className="controls team-controls">
      <div className={`columns is-multiline ${reverseClass}`}>
        <div
          className={`team-name column is-7 is-flex is-align-items-center ${teamNameClass}`}
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

function TeamControls({ team, clock_state, teamType }: TeamControlsProps) {
  const { t } = useTranslation();
  const reverseClass =
    teamType === 'away' ? 'is-flex-direction-row-reverse' : '';
  const teamNameClass = teamType === 'away' ? 'is-justify-content-right' : '';
  const teamCaption =
    teamType === 'home'
      ? t('basketball.teams.teamA')
      : t('basketball.teams.teamB');
  return (
    <div className="controls team-controls">
      <span className={`caption ${teamType}`}>{teamCaption}</span>
      <div className={`columns is-multiline ${reverseClass}`}>
        <div
          className={`team-name column is-7 is-flex is-align-items-center ${teamNameClass}`}
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
          <TeamStats team={team} clock_state={clock_state} />
        </div>
      </div>
    </div>
  );
}

export default TeamControls;
