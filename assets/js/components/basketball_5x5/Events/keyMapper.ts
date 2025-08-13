const KEY_TO_EVENT_TYPE_KEY: { [key: string]: string } = {
  'add-coach-to-team': 'basketball.modals.eventLogs.eventKeys.addCoachToTeam',
  'add-official-to-game':
    'basketball.modals.eventLogs.eventKeys.addOfficialToGame',
  'add-player-to-team': 'basketball.modals.eventLogs.eventKeys.addPlayerToTeam',
  'end-game': 'basketball.modals.eventLogs.eventKeys.endGame',
  'end-game-live-mode': 'basketball.modals.eventLogs.eventKeys.endGameLiveMode',
  'end-period': 'basketball.modals.eventLogs.eventKeys.endPeriod',
  'game-tick': 'basketball.modals.eventLogs.eventKeys.gameTick',
  'load-from-last-event-log':
    'basketball.modals.eventLogs.eventKeys.loadFromLastEventLog',
  'remove-coach-in-team':
    'basketball.modals.eventLogs.eventKeys.removeCoachInTeam',
  'remove-official-in-game':
    'basketball.modals.eventLogs.eventKeys.removeOfficialInGame',
  'remove-player-in-team':
    'basketball.modals.eventLogs.eventKeys.removePlayerInTeam',
  'reset-game-live-mode':
    'basketball.modals.eventLogs.eventKeys.resetGameLiveMode',
  'start-game': 'basketball.modals.eventLogs.eventKeys.startGame',
  'start-game-live-mode':
    'basketball.modals.eventLogs.eventKeys.startGameLiveMode',
  'substitute-player': 'basketball.modals.eventLogs.eventKeys.substitutePlayer',
  'update-clock-state':
    'basketball.modals.eventLogs.eventKeys.updateClockState',
  'update-clock-time-and-period':
    'basketball.modals.eventLogs.eventKeys.updateClockTimeAndPeriod',
  'update-coach-in-team':
    'basketball.modals.eventLogs.eventKeys.updateCoachInTeam',
  'update-coach-stat': 'basketball.modals.eventLogs.eventKeys.updateCoachStat',
  'update-official-in-game':
    'basketball.modals.eventLogs.eventKeys.updateOfficialInGame',
  'update-player-stat':
    'basketball.modals.eventLogs.eventKeys.updatePlayerStat',
  'update-player-in-team':
    'basketball.modals.eventLogs.eventKeys.updatePlayerInTeam',
  'update-team-stat': 'basketball.modals.eventLogs.eventKeys.updateTeamStat',
};

export function keyToEventTypeKey(statId: string) {
  return KEY_TO_EVENT_TYPE_KEY[statId] || '';
}
