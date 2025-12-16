import {
  sortPlayers,
  wherePlaying,
  whereNotPlaying,
  byPlayer,
  getPlayerTooltipText,
  TranslationFunction,
  getPlayerButtonClassName,
  UserActionState,
} from '../utils';
import { PlayerState } from '../../../../types';

describe('Players utils', () => {
  const createPlayer = (
    name: string,
    number: string = '',
    state: PlayerState['state'] = 'available',
  ): PlayerState => ({
    id: `player-${name}`,
    name,
    number,
    license_number: '',
    state,
    stats_values: {},
    is_captain: false,
  });

  describe('wherePlaying', () => {
    it('returns true for playing players', () => {
      const player = createPlayer('John', '10', 'playing');
      expect(wherePlaying(player)).toBe(true);
    });

    it('returns false for non-playing players', () => {
      const benchPlayer = createPlayer('Jane', '5', 'bench');
      const injuredPlayer = createPlayer('Bob', '3', 'injured');
      const unavailablePlayer = createPlayer('Alice', '7', 'not_available');

      expect(wherePlaying(benchPlayer)).toBe(false);
      expect(wherePlaying(injuredPlayer)).toBe(false);
      expect(wherePlaying(unavailablePlayer)).toBe(false);
    });
  });

  describe('whereNotPlaying', () => {
    it('returns true for bench and injured players', () => {
      const benchPlayer = createPlayer('Jane', '5', 'bench');
      const injuredPlayer = createPlayer('Bob', '3', 'injured');
      const availablePlayer = createPlayer('Charlie', '8', 'available');

      expect(whereNotPlaying(benchPlayer)).toBe(true);
      expect(whereNotPlaying(injuredPlayer)).toBe(true);
      expect(whereNotPlaying(availablePlayer)).toBe(true);
    });

    it('returns false for playing and unavailable players', () => {
      const playingPlayer = createPlayer('John', '10', 'playing');
      const unavailablePlayer = createPlayer('Alice', '7', 'not_available');

      expect(whereNotPlaying(playingPlayer)).toBe(false);
      expect(whereNotPlaying(unavailablePlayer)).toBe(false);
    });
  });

  describe('byPlayer', () => {
    it('sorts players with numbers by number value', () => {
      const player1 = createPlayer('Alice', '10');
      const player2 = createPlayer('Bob', '5');
      const player3 = createPlayer('Charlie', '20');

      const sorted = [player1, player2, player3].sort(byPlayer);
      expect(sorted).toEqual([player2, player1, player3]); // 5, 10, 20
    });

    it('puts players with numbers before players without numbers', () => {
      const playerWithNumber = createPlayer('Alice', '10');
      const playerWithoutNumber = createPlayer('Bob', '');

      const sorted = [playerWithoutNumber, playerWithNumber].sort(byPlayer);
      expect(sorted).toEqual([playerWithNumber, playerWithoutNumber]);
    });

    it('sorts players without numbers alphabetically by name', () => {
      const player1 = createPlayer('Charlie', '');
      const player2 = createPlayer('Alice', '');
      const player3 = createPlayer('Bob', '');

      const sorted = [player1, player2, player3].sort(byPlayer);
      expect(sorted).toEqual([player2, player3, player1]); // Alice, Bob, Charlie
    });

    it('handles mixed scenarios correctly', () => {
      const player1 = createPlayer('Zane', '5');
      const player2 = createPlayer('Alice', '');
      const player3 = createPlayer('Bob', '10');
      const player4 = createPlayer('Charlie', '');

      const sorted = [player2, player3, player4, player1].sort(byPlayer);
      expect(sorted).toEqual([player1, player3, player2, player4]); // 5, 10, Alice, Charlie
    });

    it('handles invalid number strings', () => {
      const player1 = createPlayer('Alice', 'abc');
      const player2 = createPlayer('Bob', '10');
      const player3 = createPlayer('Charlie', '');

      const sorted = [player1, player2, player3].sort(byPlayer);
      expect(sorted).toEqual([player2, player1, player3]); // 10, Alice (invalid number), Charlie (no number)
    });
  });

  describe('sortPlayers', () => {
    it('sorts players by number first, then by name', () => {
      const players = [
        createPlayer('Charlie', ''),
        createPlayer('Alice', '10'),
        createPlayer('Bob', '5'),
        createPlayer('Dave', ''),
      ];

      const sorted = sortPlayers(players);
      expect(sorted.map((p) => p.name)).toEqual([
        'Bob',
        'Alice',
        'Charlie',
        'Dave',
      ]);
    });

    it('returns a new array without mutating the original', () => {
      const players = [createPlayer('Bob', '10'), createPlayer('Alice', '5')];
      const original = [...players];

      const sorted = sortPlayers(players);

      expect(players).toEqual(original);
      expect(sorted).not.toBe(players);
      expect(sorted.map((p) => p.name)).toEqual(['Alice', 'Bob']);
    });

    it('handles empty array', () => {
      const sorted = sortPlayers([]);
      expect(sorted).toEqual([]);
    });

    it('handles single player', () => {
      const player = createPlayer('Alice', '10');
      const sorted = sortPlayers([player]);
      expect(sorted).toEqual([player]);
    });

    it('maintains stability for players with same sort criteria', () => {
      const player1 = createPlayer('Alice', '');
      const player2 = createPlayer('Alice', '');

      const sorted = sortPlayers([player1, player2]);
      expect(sorted).toEqual([player1, player2]);
    });
  });

  describe('getPlayerTooltipText', () => {
    const mockT: TranslationFunction = (key: string) => {
      const translations: Record<string, string> = {
        'basketball.players.disqualified': 'Disqualified',
        'basketball.players.warningTechnical': 'Technical Foul',
        'basketball.players.warningUnsportsmanlike': 'Unsportsmanlike Foul',
      };
      return translations[key] || key;
    };

    const createPlayerWithStats = (
      name: string,
      state: PlayerState['state'] = 'available',
      stats_values: Record<string, number> = {},
    ): PlayerState => ({
      id: `player-${name}`,
      name,
      number: '10',
      license_number: '',
      state,
      stats_values,
      is_captain: false,
    });

    it('returns disqualified message for disqualified players', () => {
      const player = createPlayerWithStats('John', 'disqualified');
      const result = getPlayerTooltipText(player, mockT);
      expect(result).toBe('Disqualified');
    });

    it('returns undefined for players with no fouls or issues', () => {
      const player = createPlayerWithStats('John', 'playing');
      const result = getPlayerTooltipText(player, mockT);
      expect(result).toBeUndefined();
    });

    it('returns technical foul warning with count', () => {
      const player = createPlayerWithStats('John', 'playing', {
        fouls_technical: 1,
      });
      const result = getPlayerTooltipText(player, mockT);
      expect(result).toBe('Technical Foul (1)');
    });

    it('returns unsportsmanlike foul warning with count', () => {
      const player = createPlayerWithStats('John', 'playing', {
        fouls_unsportsmanlike: 1,
      });
      const result = getPlayerTooltipText(player, mockT);
      expect(result).toBe('Unsportsmanlike Foul (1)');
    });

    it('returns combined warning for both foul types', () => {
      const player = createPlayerWithStats('John', 'playing', {
        fouls_technical: 2,
        fouls_unsportsmanlike: 1,
      });
      const result = getPlayerTooltipText(player, mockT);
      expect(result).toBe('Technical Foul (2) + Unsportsmanlike Foul (1)');
    });

    it('prioritizes disqualified status over fouls', () => {
      const player = createPlayerWithStats('John', 'disqualified', {
        fouls_technical: 1,
        fouls_unsportsmanlike: 1,
      });
      const result = getPlayerTooltipText(player, mockT);
      expect(result).toBe('Disqualified');
    });

    it('handles missing stats_values gracefully', () => {
      const player = createPlayerWithStats('John', 'playing');
      player.stats_values = {};
      const result = getPlayerTooltipText(player, mockT);
      expect(result).toBeUndefined();
    });

    it('handles zero foul counts', () => {
      const player = createPlayerWithStats('John', 'playing', {
        fouls_technical: 0,
        fouls_unsportsmanlike: 0,
      });
      const result = getPlayerTooltipText(player, mockT);
      expect(result).toBeUndefined();
    });

    it('handles high foul counts', () => {
      const player = createPlayerWithStats('John', 'playing', {
        fouls_technical: 3,
      });
      const result = getPlayerTooltipText(player, mockT);
      expect(result).toBe('Technical Foul (3)');
    });

    it('only shows warning for technical fouls >= 1', () => {
      const player = createPlayerWithStats('John', 'playing', {
        fouls_technical: 0,
      });
      const result = getPlayerTooltipText(player, mockT);
      expect(result).toBeUndefined();
    });

    it('only shows warning for unsportsmanlike fouls >= 1', () => {
      const player = createPlayerWithStats('John', 'playing', {
        fouls_unsportsmanlike: 0,
      });
      const result = getPlayerTooltipText(player, mockT);
      expect(result).toBeUndefined();
    });
  });

  describe('getPlayerButtonClassName', () => {
    const createPlayerWithStats = (
      name: string,
      state: PlayerState['state'] = 'available',
      stats_values: Record<string, number> = {},
    ): PlayerState => ({
      id: `player-${name}`,
      name,
      number: '10',
      license_number: '',
      state,
      stats_values,
      is_captain: false,
    });

    it('returns base classes for normal player', () => {
      const player = createPlayerWithStats('John', 'playing');
      const result = getPlayerButtonClassName(player, false, false);
      expect(result).toBe('player-button button');
    });

    it('adds selected class when isSelected is true', () => {
      const player = createPlayerWithStats('John', 'playing');
      const result = getPlayerButtonClassName(player, true, false);
      expect(result).toBe('player-button button is-dark');
    });

    it('adds disqualified classes for disqualified player', () => {
      const player = createPlayerWithStats('John', 'disqualified');
      const result = getPlayerButtonClassName(player, false, false);
      expect(result).toBe('player-button button is-disqualified has-tooltip');
    });

    it('adds foul trouble classes for player with technical foul', () => {
      const player = createPlayerWithStats('John', 'playing', {
        fouls_technical: 1,
      });
      const result = getPlayerButtonClassName(player, false, false);
      expect(result).toBe('player-button button has-foul-trouble has-tooltip');
    });

    it('adds foul trouble classes for player with unsportsmanlike foul', () => {
      const player = createPlayerWithStats('John', 'playing', {
        fouls_unsportsmanlike: 1,
      });
      const result = getPlayerButtonClassName(player, false, false);
      expect(result).toBe('player-button button has-foul-trouble has-tooltip');
    });

    it('combines selected and foul trouble classes', () => {
      const player = createPlayerWithStats('John', 'playing', {
        fouls_technical: 1,
      });
      const result = getPlayerButtonClassName(player, true, false);
      expect(result).toBe(
        'player-button button is-dark has-foul-trouble has-tooltip',
      );
    });

    it('prioritizes disqualified over foul trouble', () => {
      const player = createPlayerWithStats('John', 'disqualified', {
        fouls_technical: 1,
      });
      const result = getPlayerButtonClassName(player, false, false);
      expect(result).toBe('player-button button is-disqualified has-tooltip');
    });

    it('handles disabled prop correctly', () => {
      const player = createPlayerWithStats('John', 'playing');
      const result = getPlayerButtonClassName(player, false, true);
      expect(result).toBe('player-button button');
    });

    it('disqualified player is treated as disabled even when selected', () => {
      const player = createPlayerWithStats('John', 'disqualified');
      const result = getPlayerButtonClassName(player, true, false);
      expect(result).toBe('player-button button is-disqualified has-tooltip');
    });

    it('includes custom className when provided', () => {
      const player = createPlayerWithStats('John', 'playing');
      const result = getPlayerButtonClassName(
        player,
        false,
        false,
        'custom-class',
      );
      expect(result).toBe('player-button button custom-class');
    });

    it('combines all classes correctly', () => {
      const player = createPlayerWithStats('John', 'playing', {
        fouls_technical: 1,
      });
      const result = getPlayerButtonClassName(
        player,
        true,
        false,
        'custom-class another-class',
      );
      expect(result).toBe(
        'player-button button is-dark has-foul-trouble has-tooltip custom-class another-class',
      );
    });

    it('handles empty custom className', () => {
      const player = createPlayerWithStats('John', 'playing');
      const result = getPlayerButtonClassName(player, false, false, '');
      expect(result).toBe('player-button button');
    });

    it('handles undefined stats_values', () => {
      const player = createPlayerWithStats('John', 'playing');
      player.stats_values = {};
      const result = getPlayerButtonClassName(player, false, false);
      expect(result).toBe('player-button button');
    });

    it('requires both technical and unsportsmanlike fouls to be >= 1 for warning', () => {
      const playerWithZeroTech = createPlayerWithStats('John', 'playing', {
        fouls_technical: 0,
        fouls_unsportsmanlike: 1,
      });
      const result1 = getPlayerButtonClassName(
        playerWithZeroTech,
        false,
        false,
      );
      expect(result1).toBe('player-button button has-foul-trouble has-tooltip');

      const playerWithZeroUnsport = createPlayerWithStats('John', 'playing', {
        fouls_technical: 1,
        fouls_unsportsmanlike: 0,
      });
      const result2 = getPlayerButtonClassName(
        playerWithZeroUnsport,
        false,
        false,
      );
      expect(result2).toBe('player-button button has-foul-trouble has-tooltip');

      const playerWithBothZero = createPlayerWithStats('John', 'playing', {
        fouls_technical: 0,
        fouls_unsportsmanlike: 0,
      });
      const result3 = getPlayerButtonClassName(
        playerWithBothZero,
        false,
        false,
      );
      expect(result3).toBe('player-button button');
    });
  });
});
