import React from 'react';
import { GameState, DEFAULT_GAME_STATE, TeamState } from '../types';
import { formatTime } from '../shared/contentHelpers';
import { useTranslation } from 'react-i18next';

interface StreamViewsProps {
  game_data: string;
}

// Utility function to calculate contrast color
function getContrastColor(hex: string): string {
  // Remove the hash at the start if it's there
  hex = hex.replace(/^#/, '');

  // Parse the r, g, b values
  let r = parseInt(hex.substring(0, 2), 16);
  let g = parseInt(hex.substring(2, 4), 16);
  let b = parseInt(hex.substring(4, 6), 16);

  // Calculate the luminance
  let luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;

  // Return black for light colors and white for dark colors
  return luminance > 0.5 ? '#1e1200' : '#fdfdff';
}

function AnimatedScore({ score }: { score: number }) {
  const [currentScore, setCurrentScore] = React.useState(0);
  const [scoreMadeEffect, setScoreMakeEffect] = React.useState(false);
  const [scoreDiff, setScoreDiff] = React.useState(1);

  React.useEffect(() => {
    setScoreDiff(score - currentScore);
  }, [score]);

  React.useEffect(() => {
    setScoreMakeEffect(true);
    const timeoutScore = setTimeout(() => {
      setCurrentScore(score);
    }, 600);
    const timeoutScoreMake = setTimeout(() => {
      setScoreMakeEffect(false);
      setScoreDiff(1);
    }, 2000);
    return () => {
      clearTimeout(timeoutScoreMake);
      clearTimeout(timeoutScore);
    };
  }, [score]);

  return (
    <div className="animated-score">
      <span className={`score-effect ${scoreMadeEffect ? `show` : 'hide'}`}>
        {scoreDiff > 0 ? `+${scoreDiff}` : ''}
      </span>
      <span className="score">{currentScore}</span>
    </div>
  );
}

function TeamScore({
  team,
  score,
  defaultColor,
  currentPeriod,
}: {
  team: TeamState;
  score: number;
  defaultColor: string;
  currentPeriod: number;
}) {
  const { t } = useTranslation();
  const [color, setColor] = React.useState(defaultColor);
  const [contrastColor, setContrastColor] = React.useState('#FFFFFF');
  const quarteFouls =
    currentPeriod && team.period_stats[currentPeriod]
      ? team.period_stats[currentPeriod]['fouls'] || 0
      : 0;

  const handleColorChange = (color: string) => {
    setColor(color);
    setContrastColor(getContrastColor(color));
  };

  const shouldUseLogoAndTriCode = team.logo_url && team.tri_code;

  return (
    <div className="column is-12">
      <div className="team-score">
        <div className="identifier">
          {shouldUseLogoAndTriCode ? (
            <>
              <img className="logo" src={team.logo_url} alt={team.tri_code} />
              <span className="tri-code" style={{ color: contrastColor }}>
                {team.tri_code}
              </span>
            </>
          ) : (
            <span className="text" style={{ color: contrastColor }}>
              {team.tri_code || team.name}
            </span>
          )}

          <input
            type="color"
            value={color}
            onChange={(e) => handleColorChange(e.target.value)}
          />
        </div>
        <div className="score">
          <AnimatedScore score={score} />
        </div>
      </div>
      <div
        className="fouls"
        style={{ backgroundColor: color, color: contrastColor }}
      >
        {t('basketball.streamViewer.teamScore.fouls').toUpperCase()}:{' '}
        {quarteFouls}
      </div>
    </div>
  );
}

function StreamViews({ game_data }: StreamViewsProps) {
  const object = JSON.parse(game_data);
  const game_state = (object.result as GameState) || DEFAULT_GAME_STATE;
  return (
    <div className="stream-views">
      <div className="columns is-multiline is-vcentered">
        <div className="column has-text-centered away">
          <TeamScore
            team={game_state.home_team}
            score={game_state.home_team.stats_values['points'] || 0}
            defaultColor="#2b5615"
            currentPeriod={game_state.clock_state.period}
          />
        </div>
        <div className="column has-text-centered home">
          <TeamScore
            team={game_state.away_team}
            score={game_state.away_team.stats_values['points'] || 0}
            defaultColor="#970c10"
            currentPeriod={game_state.clock_state.period}
          />
        </div>
        <div className="column is-3 has-text-centered time-ad">
          <div className="period-time">
            <span className="period">
              {`${game_state.clock_state.period}º`}
            </span>
            <div className="time">
              <span>{formatTime(game_state.clock_state.time)}</span>
            </div>
          </div>
          <div className="ad">
            <span>go-champs.com</span>
          </div>
        </div>
      </div>
    </div>
  );
}

export default StreamViews;
