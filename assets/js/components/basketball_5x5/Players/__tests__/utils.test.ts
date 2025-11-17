import { sortPlayers, wherePlaying, whereNotPlaying, byPlayer } from '../utils';
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
});
