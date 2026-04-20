import React from 'react';
import { GameState, DEFAULT_GAME_STATE, TeamState, PlayerState, EventLog, EventLogUpdatePlayerStatPayload } from '../types';
import { formatTime } from '../shared/contentHelpers';
import { getContrastColor } from '../shared/styleHelpers';
import { useTranslation } from 'react-i18next';

interface StreamViewsProps {
  game_data: string;
  recent_events_data: string;
}

interface PlayerScoreNotificationData {
  id: string;
  playerName: string;
  playerNumber: string;
  points: number;
  rebounds: number;
  assists: number;
  teamColor: string;
}

const SCORING_STATS = ['field_goals_made', 'free_throws_made', 'three_point_field_goals_made'];

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

function PlayerScoreNotification({ notification }: { notification: PlayerScoreNotificationData | null }) {
  const [isVisible, setIsVisible] = React.useState(false);
  const [isExiting, setIsExiting] = React.useState(false);
  const { t } = useTranslation();
  const contrastColor = React.useMemo(
    () => notification ? getContrastColor(notification.teamColor) : '#FFFFFF',
    [notification?.teamColor]
  );

  React.useEffect(() => {
    if (notification) {
      setIsVisible(true);
      setIsExiting(false);
      
      // Start exit animation after 4 seconds
      const exitTimer = setTimeout(() => {
        setIsExiting(true);
      }, 4000);
      
      // Hide completely after exit animation (4s + 0.5s animation)
      const hideTimer = setTimeout(() => {
        setIsVisible(false);
      }, 4500);
      
      return () => {
        clearTimeout(exitTimer);
        clearTimeout(hideTimer);
      };
    }
  }, [notification]);

  if (!isVisible || !notification) {
    return null;
  }

  return (
    <div 
      className={`player-score-notification ${isExiting ? 'exiting' : 'entering'}`}
      style={{ 
        backgroundColor: notification.teamColor,
        color: contrastColor
      }}
    >
      <div className="player-info">
        <span className="player-number">#{notification.playerNumber}</span>
        <span className="player-name">{notification.playerName}</span>
      </div>
      <div className="player-stats">
        <div className="stat-item">
          <span className="stat-value">{notification.points}</span>
          <span className="stat-label">{t('basketball.streamViewer.playerNotification.points').toUpperCase()}</span>
        </div>
        <div className="stat-item">
          <span className="stat-value">{notification.rebounds}</span>
          <span className="stat-label">{t('basketball.streamViewer.playerNotification.rebounds').toUpperCase()}</span>
        </div>
        <div className="stat-item">
          <span className="stat-value">{notification.assists}</span>
          <span className="stat-label">{t('basketball.streamViewer.playerNotification.assists').toUpperCase()}</span>
        </div>
      </div>
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
  React.useEffect(() => {
    setColor(defaultColor);
    setContrastColor(getContrastColor(defaultColor));
  }, [defaultColor]);
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

function StreamViews({ game_data, recent_events_data }: StreamViewsProps) {
  const object = JSON.parse(game_data);
  const game_state = (object.result as GameState) || DEFAULT_GAME_STATE;
  
  const events_object = JSON.parse(recent_events_data);
  const recent_events = (events_object.result as EventLog[]) || [];
  
  const [currentNotification, setCurrentNotification] = React.useState<PlayerScoreNotificationData | null>(null);
  const [notificationQueue, setNotificationQueue] = React.useState<PlayerScoreNotificationData[]>([]);
  const processedEventIds = React.useRef<Set<string>>(new Set());

  // Process new events to create notifications
  React.useEffect(() => {
    const newNotifications: PlayerScoreNotificationData[] = [];
    
    for (const event of recent_events) {
      // Skip if already processed
      if (processedEventIds.current.has(event.id)) {
        continue;
      }
      
      // Only process update-player-stat events
      if (event.key !== 'update-player-stat') {
        continue;
      }
      
      const payload = event.payload as EventLogUpdatePlayerStatPayload;
      
      // Only show for scoring stats and increment operations
      if (!payload || !SCORING_STATS.includes(payload['stat-id']) || payload['operation'] !== 'increment') {
        continue;
      }
      
      // Find the player
      const team = payload['team-type'] === 'home' ? game_state.home_team : game_state.away_team;
      const player = team.players.find(p => p.id === payload['player-id']);
      
      if (!player) {
        continue;
      }
      
      // Calculate stats
      const points = player.stats_values['points'] || 0;
      const reboundsDefensive = player.stats_values['rebounds_defensive'] || 0;
      const reboundsOffensive = player.stats_values['rebounds_offensive'] || 0;
      const rebounds = reboundsDefensive + reboundsOffensive;
      const assists = player.stats_values['assists'] || 0;
      
      newNotifications.push({
        id: event.id,
        playerName: player.name,
        playerNumber: player.number,
        points,
        rebounds,
        assists,
        teamColor: team.primary_color || '#2b5615'
      });
      
      // Mark as processed
      processedEventIds.current.add(event.id);
    }
    
    if (newNotifications.length > 0) {
      setNotificationQueue(prev => [...prev, ...newNotifications]);
    }
  }, [recent_events, game_state]);

  // Process notification queue
  React.useEffect(() => {
    if (!currentNotification && notificationQueue.length > 0) {
      const [nextNotification, ...rest] = notificationQueue;
      setCurrentNotification(nextNotification);
      setNotificationQueue(rest);
      
      // Clear current notification after display time (4s visible + 0.5s exit animation)
      const clearTimer = setTimeout(() => {
        setCurrentNotification(null);
      }, 4500);
      
      return () => clearTimeout(clearTimer);
    }
  }, [currentNotification, notificationQueue]);

  return (
    <div className="stream-views">
      <PlayerScoreNotification notification={currentNotification} />
      <div className="columns is-multiline is-vcentered">
        <div className="column has-text-centered away">
          <TeamScore
            team={game_state.home_team}
            score={game_state.home_team.stats_values['points'] || 0}
            defaultColor={game_state.home_team.primary_color || '#2b5615'}
            currentPeriod={game_state.clock_state.period}
          />
        </div>
        <div className="column has-text-centered home">
          <TeamScore
            team={game_state.away_team}
            score={game_state.away_team.stats_values['points'] || 0}
            defaultColor={game_state.away_team.primary_color || '#970c10'}
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
