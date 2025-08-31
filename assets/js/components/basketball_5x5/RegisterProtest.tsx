import React, { useState } from 'react';
import { GameState, TeamType, PlayerState } from '../../types';
import { useTranslation } from '../../hooks/useTranslation';

interface RegisterProtestProps {
  game_state: GameState;
  pushEvent: (event: string, payload: any) => void;
}

function RegisterProtest({ game_state, pushEvent }: RegisterProtestProps) {
  const { t } = useTranslation();
  const [selectedTeamType, setSelectedTeamType] = useState<TeamType | ''>('');
  const [selectedPlayerId, setSelectedPlayerId] = useState<string>('');

  const handleProtest = (
    selectedTeamType: TeamType,
    selectedPlayerId: string,
  ) => {
    pushEvent('protest-game', {
      ['team-type']: selectedTeamType,
      ['player-id']: selectedPlayerId,
    });
  };

  const handleTeamChange = (event: React.ChangeEvent<HTMLSelectElement>) => {
    const teamType = event.target.value as TeamType | '';
    setSelectedTeamType(teamType);
    setSelectedPlayerId('');
  };

  const handlePlayerChange = (event: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedPlayerId(event.target.value);
  };

  const getSelectedTeam = () => {
    if (selectedTeamType === 'home') return game_state.home_team;
    if (selectedTeamType === 'away') return game_state.away_team;
    return null;
  };

  const selectedTeam = getSelectedTeam();
  const availablePlayers = selectedTeam?.players || [];
  const isProtestButtonEnabled = selectedTeamType && selectedPlayerId;

  const handleSubmitProtest = () => {
    if (selectedTeamType && selectedPlayerId) {
      handleProtest(selectedTeamType, selectedPlayerId);

      setSelectedTeamType('');
      setSelectedPlayerId('');
    }
  };

  return (
    <div className="controls" style={{ padding: '2rem 1.5rem' }}>
      <div className="columns is-multiline">
        <div className="column is-12 has-text-centered">
          <h4 className="title is-4">
            {t('basketball.protest.controls.registryProtest')}
          </h4>
        </div>

        <div className="column is-6">
          <div className="field">
            <div className="control">
              <div className="select is-fullwidth">
                <select value={selectedTeamType} onChange={handleTeamChange}>
                  <option value="">
                    {t('basketball.protest.controls.selectTeam')}
                  </option>
                  <option value="home">{game_state.home_team.name}</option>
                  <option value="away">{game_state.away_team.name}</option>
                </select>
              </div>
            </div>
          </div>
        </div>

        <div className="column is-6">
          <div className="field">
            <div className="control">
              <div className="select is-fullwidth">
                <select
                  value={selectedPlayerId}
                  onChange={handlePlayerChange}
                  disabled={!selectedTeamType}
                >
                  <option value="">
                    {t('basketball.protest.controls.selectPlayer')}
                  </option>
                  {availablePlayers.map((player: PlayerState) => (
                    <option key={player.id} value={player.id}>
                      #{player.number} - {player.name}
                    </option>
                  ))}
                </select>
              </div>
            </div>
          </div>
        </div>

        <div className="column is-12">
          <button
            className="button is-danger is-fullwidth"
            disabled={!isProtestButtonEnabled}
            onClick={handleSubmitProtest}
          >
            {t('basketball.protest.controls.registry')}
          </button>
        </div>
      </div>
    </div>
  );
}

export default RegisterProtest;
