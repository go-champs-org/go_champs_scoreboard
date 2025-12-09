import React, { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { GameState } from '../../../types';
import { byPlayer } from '../../basketball_5x5/Players/utils';
import CheckboxFormField from '../../CheckboxFormField';

interface UpdatePlayersStateFormProps {
  onChange: (updateFn: (prevPayload: any) => any) => void;
  gameState: GameState;
  initialPayload?: Record<string, any>;
}

function UpdatePlayersStateForm({
  onChange,
  gameState,
  initialPayload = {},
}: UpdatePlayersStateFormProps) {
  const { t } = useTranslation();

  const [selectedTeamType, setSelectedTeamType] = useState<
    'home' | 'away' | ''
  >(initialPayload['team-type'] || '');

  const [selectedPlayerIds, setSelectedPlayerIds] = useState<string[]>(
    initialPayload['player-ids'] || [],
  );

  const selectedTeam =
    selectedTeamType === 'home' ? gameState.home_team : gameState.away_team;
  const availablePlayers = selectedTeam?.players
    ? [...selectedTeam.players].sort(byPlayer)
    : [];

  const stateOptions = [
    { value: 'playing', label: t('basketball.players.onCourt') },
    { value: 'bench', label: t('basketball.players.onBench') },
    {
      value: 'injured',
      label: t(
        'basketball.modals.eventLogs.payloadFields.playersState.injured',
      ),
    },
    { value: 'disqualified', label: t('basketball.players.disqualified') },
    {
      value: 'available',
      label: t(
        'basketball.modals.eventLogs.payloadFields.playersState.available',
      ),
    },
    {
      value: 'not_available',
      label: t(
        'basketball.modals.eventLogs.payloadFields.playersState.notAvailable',
      ),
    },
  ];

  const handleInputChange = (field: string, value: any) => {
    onChange((prevPayload: any) => ({
      ...prevPayload,
      [field]: value,
    }));
  };

  const handleTeamChange = (teamType: 'home' | 'away' | '') => {
    setSelectedTeamType(teamType);
    setSelectedPlayerIds([]);
    handleInputChange('team-type', teamType);
    handleInputChange('player-ids', []);
  };

  const handlePlayerSelection = (playerId: string, isSelected: boolean) => {
    let updatedPlayerIds: string[];

    if (isSelected) {
      // Check if selecting this player would exceed the limit for "playing" state
      const isPlayingState = initialPayload['state'] === 'playing';
      const maxPlayers = isPlayingState ? 5 : Infinity;

      if (selectedPlayerIds.length >= maxPlayers) {
        return; // Don't allow selection if limit is reached
      }

      updatedPlayerIds = [...selectedPlayerIds, playerId];
    } else {
      updatedPlayerIds = selectedPlayerIds.filter((id) => id !== playerId);
    }

    setSelectedPlayerIds(updatedPlayerIds);
    handleInputChange('player-ids', updatedPlayerIds);
  };

  return (
    <div className="update-players-state-form">
      <div className="columns is-multiline">
        <div className="column is-4">
          <div className="field">
            <label className="label has-text-white-ter">
              {t(
                'basketball.modals.eventLogs.payloadFields.playerStat.teamType',
              )}
            </label>
            <div className="control">
              <div className="select is-fullwidth">
                <select
                  value={selectedTeamType}
                  disabled={!!initialPayload['team-type']}
                  onChange={(e) =>
                    handleTeamChange(e.target.value as 'home' | 'away' | '')
                  }
                >
                  <option value="">
                    {t(
                      'basketball.modals.eventLogs.payloadFields.playerStat.selectTeam',
                    )}
                  </option>
                  <option value="away">{gameState.away_team.name}</option>
                  <option value="home">{gameState.home_team.name}</option>
                </select>
              </div>
            </div>
          </div>
        </div>

        <div className="column is-4">
          <div className="field">
            <label className="label has-text-white-ter">
              {t(
                'basketball.modals.eventLogs.payloadFields.playersState.state',
              )}
            </label>
            <div className="control">
              <div className="select is-fullwidth">
                <select
                  value={initialPayload['state'] || ''}
                  disabled={!!initialPayload['state']}
                  onChange={(e) => handleInputChange('state', e.target.value)}
                >
                  <option value="">
                    {t(
                      'basketball.modals.eventLogs.payloadFields.playersState.selectState',
                    )}
                  </option>
                  {stateOptions.map((option) => (
                    <option key={option.value} value={option.value}>
                      {option.label}
                    </option>
                  ))}
                </select>
              </div>
            </div>
          </div>
        </div>

        <div className="column is-12">
          <div className="field">
            <label className="label has-text-white-ter">
              {t(
                'basketball.modals.eventLogs.payloadFields.playersState.players',
              )}
              {initialPayload['state'] === 'playing' && (
                <span className="has-text-info ml-2">
                  {t(
                    'basketball.modals.eventLogs.payloadFields.playersState.maxPlayersOnCourt',
                  )}
                </span>
              )}
              {selectedPlayerIds.length > 0 && (
                <span className="has-text-grey ml-2">
                  ({selectedPlayerIds.length}{' '}
                  {t(
                    'basketball.modals.eventLogs.payloadFields.playersState.playersSelected',
                  )}
                  )
                </span>
              )}
            </label>
            <div className="control">
              {!selectedTeamType ? (
                <p className="has-text-grey-light">
                  {t(
                    'basketball.modals.eventLogs.payloadFields.playerStat.selectTeamFirst',
                  )}
                </p>
              ) : availablePlayers.length === 0 ? (
                <p className="has-text-grey-light">
                  {t(
                    'basketball.modals.eventLogs.payloadFields.playersState.noPlayersAvailable',
                  )}
                </p>
              ) : (
                <div className="players-grid">
                  <div className="columns is-multiline">
                    {availablePlayers.map((player) => {
                      const isSelected = selectedPlayerIds.includes(player.id);
                      const isPlayingState =
                        initialPayload['state'] === 'playing';
                      const maxReached =
                        isPlayingState && selectedPlayerIds.length >= 5;
                      const isDisabled = !isSelected && maxReached;

                      return (
                        <div key={player.id} className="column is-3">
                          <CheckboxFormField
                            initialValue={isSelected}
                            disabled={isDisabled}
                            onChange={(checked) =>
                              handlePlayerSelection(player.id, checked)
                            }
                            label={`#${player.number} - ${player.name}`}
                            className={
                              isDisabled
                                ? 'player-checkbox has-text-grey'
                                : 'player-checkbox has-text-white-ter'
                            }
                          />
                        </div>
                      );
                    })}
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default UpdatePlayersStateForm;
