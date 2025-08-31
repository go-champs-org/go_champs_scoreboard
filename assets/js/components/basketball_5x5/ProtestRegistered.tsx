import React from 'react';
import { GameState } from '../../types';
import { useTranslation } from '../../hooks/useTranslation';

interface ProtestRegisteredProps {
  game_state: GameState;
}

function ProtestRegistered({ game_state }: ProtestRegisteredProps) {
  const { t } = useTranslation();

  const player =
    game_state.protest.team_type === 'home'
      ? game_state.home_team.players.find(
          (p) => p.id === game_state.protest.player_id,
        )
      : game_state.away_team.players.find(
          (p) => p.id === game_state.protest.player_id,
        );

  return (
    <div className="controls" style={{ padding: '2rem 1.5rem' }}>
      <div className="columns is-multiline">
        <div className="column is-12 has-text-centered">
          <h4 className="title is-4">
            {t('basketball.protest.registered.title')}
          </h4>
        </div>

        <div className="column is-12 has-text-centered">
          <p className="is-size-5">
            {t('basketball.protest.registered.message')}
          </p>
        </div>

        <div className="column is-6 has-text-centered">
          <p>
            {game_state.protest.team_type === 'home'
              ? game_state.home_team.name
              : game_state.away_team.name}
          </p>
        </div>

        <div className="column is-6 has-text-centered">
          <p>{player ? <>{player.name}</> : <></>}</p>
        </div>
      </div>
    </div>
  );
}

export default ProtestRegistered;
