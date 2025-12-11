import React, { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { GameState } from '../../../types';
import {
  TEAM_STAT_KEYS,
  TEAM_STATS,
  STAT_TYPES,
} from '../../basketball_5x5/constants';
import TeamSelect from './TeamSelect';

interface UpdateTeamStatFormProps {
  onChange: (updateFn: (prevPayload: any) => any) => void;
  gameState: GameState;
  initialPayload?: Record<string, any>;
}

const UpdateTeamStatForm: React.FC<UpdateTeamStatFormProps> = ({
  onChange,
  gameState,
  initialPayload = {},
}) => {
  const { t } = useTranslation();

  const [selectedTeamType, setSelectedTeamType] = useState<
    'home' | 'away' | ''
  >(initialPayload['team-type'] || '');

  useEffect(() => {
    if (Object.keys(initialPayload).length > 0) {
      onChange(() => initialPayload);
    }
  }, [initialPayload, onChange]);

  const manualTeamStats = TEAM_STATS.filter(
    (stat) => stat.key === TEAM_STAT_KEYS.TIMEOUTS,
  );

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
  };

  return (
    <div className="columns is-multiline">
      <div className="column is-6">
        <TeamSelect
          selectedTeamType={selectedTeamType}
          onTeamChange={handleTeamChange}
          gameState={gameState}
          disabled={!!initialPayload['team-type']}
        />
      </div>

      <div className="column is-6">
        <div className="field">
          <label className="label has-text-white-ter">
            {t('basketball.modals.eventLogs.payloadFields.teamStat.statType')}
          </label>
          <div className="control">
            <div className="select is-fullwidth">
              <select
                value={initialPayload['stat-id'] || ''}
                onChange={(e) => handleInputChange('stat-id', e.target.value)}
              >
                <option value="">
                  {t(
                    'basketball.modals.eventLogs.payloadFields.teamStat.selectStatType',
                  )}
                </option>
                {manualTeamStats.map((stat) => (
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

export default UpdateTeamStatForm;
