import { EVENT_KEYS } from '../../../constants';

const KEY_TO_EVENT_TYPE_KEY: { [key: string]: string } = {
  [EVENT_KEYS.ADD_COACH_TO_TEAM]: 'eventKeys.addCoachToTeam',
  [EVENT_KEYS.ADD_OFFICIAL_TO_GAME]: 'eventKeys.addOfficialToGame',
  [EVENT_KEYS.ADD_PLAYER_TO_TEAM]: 'eventKeys.addPlayerToTeam',
  [EVENT_KEYS.END_GAME]: 'eventKeys.endGame',
  [EVENT_KEYS.END_GAME_LIVE_MODE]: 'eventKeys.endGameLiveMode',
  [EVENT_KEYS.END_PERIOD]: 'eventKeys.endPeriod',
  [EVENT_KEYS.GAME_TICK]: 'eventKeys.gameTick',
  [EVENT_KEYS.LOAD_FROM_LAST_EVENT_LOG]: 'eventKeys.loadFromLastEventLog',
  [EVENT_KEYS.PROTEST_GAME]: 'eventKeys.protestGame',
  [EVENT_KEYS.REGISTER_TEAM_WO]: 'eventKeys.registerTeamWO',
  [EVENT_KEYS.REMOVE_COACH_IN_TEAM]: 'eventKeys.removeCoachInTeam',
  [EVENT_KEYS.REMOVE_OFFICIAL_IN_GAME]: 'eventKeys.removeOfficialInGame',
  [EVENT_KEYS.REMOVE_PLAYER_IN_TEAM]: 'eventKeys.removePlayerInTeam',
  [EVENT_KEYS.RESET_GAME_LIVE_MODE]: 'eventKeys.resetGameLiveMode',
  [EVENT_KEYS.START_GAME]: 'eventKeys.startGame',
  [EVENT_KEYS.START_GAME_LIVE_MODE]: 'eventKeys.startGameLiveMode',
  [EVENT_KEYS.SUBSTITUTE_PLAYER]: 'eventKeys.substitutePlayer',
  [EVENT_KEYS.UPDATE_CLOCK_STATE]: 'eventKeys.updateClockState',
  [EVENT_KEYS.UPDATE_CLOCK_STATE_METADATA]:
    'eventKeys.updateClockStateMetadata',
  [EVENT_KEYS.UPDATE_CLOCK_TIME_AND_PERIOD]:
    'eventKeys.updateClockTimeAndPeriod',
  [EVENT_KEYS.UPDATE_COACH_IN_TEAM]: 'eventKeys.updateCoachInTeam',
  [EVENT_KEYS.UPDATE_COACH_STAT]: 'eventKeys.updateCoachStat',
  [EVENT_KEYS.UPDATE_GAME_INFO]: 'eventKeys.updateGameInfo',
  [EVENT_KEYS.UPDATE_OFFICIAL_IN_GAME]: 'eventKeys.updateOfficialInGame',
  [EVENT_KEYS.UPDATE_PLAYER_STAT]: 'eventKeys.updatePlayerStat',
  [EVENT_KEYS.UPDATE_PLAYER_IN_TEAM]: 'eventKeys.updatePlayerInTeam',
  [EVENT_KEYS.UPDATE_PLAYERS_STATE]: 'eventKeys.updatePlayersState',
  [EVENT_KEYS.UPDATE_TEAM_STAT]: 'eventKeys.updateTeamStat',
};

export function keyToEventTypeKey(statId: string) {
  return KEY_TO_EVENT_TYPE_KEY[statId] || '';
}
