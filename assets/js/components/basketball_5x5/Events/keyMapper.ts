const KEY_TO_EVENT_TYPE_KEY: { [key: string]: string } = {
  'add-coach-to-team': 'eventKeys.addCoachToTeam',
  'add-official-to-game': 'eventKeys.addOfficialToGame',
  'add-player-to-team': 'eventKeys.addPlayerToTeam',
  'end-game': 'eventKeys.endGame',
  'end-game-live-mode': 'eventKeys.endGameLiveMode',
  'end-period': 'eventKeys.endPeriod',
  'game-tick': 'eventKeys.gameTick',
  'load-from-last-event-log': 'eventKeys.loadFromLastEventLog',
  'remove-coach-in-team': 'eventKeys.removeCoachInTeam',
  'remove-official-in-game': 'eventKeys.removeOfficialInGame',
  'remove-player-in-team': 'eventKeys.removePlayerInTeam',
  'reset-game-live-mode': 'eventKeys.resetGameLiveMode',
  'start-game': 'eventKeys.startGame',
  'start-game-live-mode': 'eventKeys.startGameLiveMode',
  'substitute-player': 'eventKeys.substitutePlayer',
  'update-clock-state': 'eventKeys.updateClockState',
  'update-clock-time-and-period': 'eventKeys.updateClockTimeAndPeriod',
  'update-coach-in-team': 'eventKeys.updateCoachInTeam',
  'update-coach-stat': 'eventKeys.updateCoachStat',
  'update-official-in-game': 'eventKeys.updateOfficialInGame',
  'update-player-stat': 'eventKeys.updatePlayerStat',
  'update-player-in-team': 'eventKeys.updatePlayerInTeam',
  'update-team-stat': 'eventKeys.updateTeamStat',
};

export function keyToEventTypeKey(statId: string) {
  return KEY_TO_EVENT_TYPE_KEY[statId] || '';
}
