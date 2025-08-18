import React, { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { GameState } from '../../../types';
import { getManualPlayerStatsForView } from '../../basketball_5x5/constants';

interface UpdatePlayerStatFormProps {
  onChange: (updateFn: (prevPayload: any) => any) => void;
  gameState: GameState;
}

const UpdatePlayerStatForm: React.FC<UpdatePlayerStatFormProps> = ({
  onChange,
  gameState,
}) => {
  const { t } = useTranslation();
  const [selectedTeamType, setSelectedTeamType] = useState<
    'home' | 'away' | ''
  >('');

  const manualStats = getManualPlayerStatsForView(
    gameState.view_settings_state.view,
  );
  const selectedTeam =
    selectedTeamType === 'home' ? gameState.home_team : gameState.away_team;
  const availablePlayers = selectedTeam?.players || [];

  const handleInputChange = (field: string, value: any) => {
    onChange((prevPayload: any) => ({
      ...prevPayload,
      [field]: value,
      operation: 'increment',
    }));
  };

  const handleTeamChange = (teamType: 'home' | 'away' | '') => {
    setSelectedTeamType(teamType);
    handleInputChange('team-type', teamType);
    handleInputChange('player-id', '');
  };

  return (
    <div className="columns is-multiline">
      <div className="column is-4">
        <div className="field">
          <label className="label has-text-white-ter">
            {t('basketball.modals.eventLogs.payloadFields.playerStat.teamType')}
          </label>
          <div className="control">
            <div className="select is-fullwidth">
              <select
                value={selectedTeamType}
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
            {t('basketball.modals.eventLogs.payloadFields.playerStat.playerId')}
          </label>
          <div className="control">
            <div className="select is-fullwidth">
              <select
                disabled={!selectedTeamType}
                onChange={(e) => handleInputChange('player-id', e.target.value)}
              >
                <option value="">
                  {selectedTeamType
                    ? t(
                        'basketball.modals.eventLogs.payloadFields.playerStat.selectPlayer',
                      )
                    : t(
                        'basketball.modals.eventLogs.payloadFields.playerStat.selectTeamFirst',
                      )}
                </option>
                {availablePlayers.map((player) => (
                  <option key={player.id} value={player.id}>
                    {player.number} - {player.name}
                  </option>
                ))}
              </select>
            </div>
          </div>
        </div>
      </div>

      <div className="column is-4">
        <div className="field">
          <label className="label has-text-white-ter">
            {t('basketball.modals.eventLogs.payloadFields.playerStat.statType')}
          </label>
          <div className="control">
            <div className="select is-fullwidth">
              <select
                onChange={(e) => handleInputChange('stat-id', e.target.value)}
              >
                <option value="">
                  {t(
                    'basketball.modals.eventLogs.payloadFields.playerStat.selectStatType',
                  )}
                </option>
                {manualStats.map((stat) => (
                  <option key={stat.key} value={stat.key}>
                    {t(stat.labelTranslationKey)}
                  </option>
                ))}
              </select>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default UpdatePlayerStatForm;
