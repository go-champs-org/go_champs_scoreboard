import { TFunction } from 'i18next';
import {
  DEFAULT_PLAYER_STATE,
  EventLogUpdatePlayerStatPayload,
  GameState,
} from '../../types';
import { statIdToAbbreviationKey } from '../basketball_5x5/Stats/statsMapper';

export function payloadToString(
  payload: EventLogUpdatePlayerStatPayload,
  game_state: GameState,
  t: TFunction,
) {
  const team =
    payload['team-type'] === 'home'
      ? game_state.home_team
      : game_state.away_team;
  const player =
    team.players.find((p) => p.id === payload['player-id']) ||
    DEFAULT_PLAYER_STATE;
  const statKey = statIdToAbbreviationKey(payload['stat-id']);
  return `${team.name} - ${player.name} | ${t(statKey)}`;
}
