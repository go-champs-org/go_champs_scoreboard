export type ApiResponse<T> = {
  data: T;
};

export interface EventLog {
  id: string;
  key: string;
  timestamp: string;
  payload: object;
  game_clock_time: number;
  game_clock_period: number;
}

export interface CoachState {
  id: string;
  name: string;
  type: 'head_coach' | 'assistant_coach';
  stats_values: { [key: string]: number };
  state: 'available' | 'not_available';
}

export interface PlayerState {
  state:
    | 'playing'
    | 'bench'
    | 'injured'
    | 'suspended'
    | 'available'
    | 'not_available';
  id: string;
  name: string;
  number: string;
  stats_values: { [key: string]: number };
}

export interface TeamState {
  name: string;
  players: PlayerState[];
  total_player_stats: { [key: string]: number };
  stats_values: { [key: string]: number };
  tri_code: string;
  logo_url: string;
  coaches: CoachState[];
}

export interface GameClockState {
  initial_period_time: number;
  time: number;
  period: number;
  state: 'not_started' | 'running' | 'paused' | 'stopped';
}

export interface LiveState {
  state: 'not_started' | 'in_progress' | 'ended';
  started_at: string;
  ended_at: string;
}

export interface ViewSettingsState {
  view: 'basketball-medium' | 'basketball-basic';
}

export interface GameState {
  id: string;
  away_team: TeamState;
  home_team: TeamState;
  sport_id: string;
  clock_state: GameClockState;
  live_state: LiveState;
  view_settings_state: ViewSettingsState;
}

export type TeamType = 'home' | 'away';

export const DEFAULT_GAME_STATE = {
  id: '',
  away_team: {
    name: '',
    players: [],
    total_player_stats: {},
    stats_values: {},
    tri_code: '',
    logo_url: '',
  },
  home_team: {
    name: '',
    players: [],
    total_player_stats: {},
    stats_values: {},
    tri_code: '',
    logo_url: '',
  },
  sport_id: '',
  clock_state: {
    initial_period_time: 0,
    time: 0,
    period: 0,
    state: 'not_started',
  },
  live_state: {
    state: 'not_started',
    started_at: '',
    ended_at: '',
  },
  view_settings_state: {
    view: 'basketball-medium',
  },
} as GameState;
