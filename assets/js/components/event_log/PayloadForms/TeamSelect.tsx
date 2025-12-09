import React from 'react';
import { useTranslation } from 'react-i18next';
import { GameState } from '../../../types';

interface TeamSelectProps {
  selectedTeamType: 'home' | 'away' | '';
  onTeamChange: (teamType: 'home' | 'away' | '') => void;
  gameState: GameState;
  disabled?: boolean;
  label?: string;
}

const TeamSelect: React.FC<TeamSelectProps> = ({
  selectedTeamType,
  onTeamChange,
  gameState,
  disabled = false,
  label,
}) => {
  const { t } = useTranslation();

  const defaultLabel = t(
    'basketball.modals.eventLogs.payloadFields.playerStat.teamType',
  );

  return (
    <div className="field">
      <label className="label has-text-white-ter">
        {label || defaultLabel}
      </label>
      <div className="control">
        <div className="select is-fullwidth">
          <select
            value={selectedTeamType}
            disabled={disabled}
            onChange={(e) =>
              onTeamChange(e.target.value as 'home' | 'away' | '')
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
  );
};

export default TeamSelect;
