import React, { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { GameState } from '../../../types';
import {
  getManualPlayerStatsForView,
  STAT_KEYS,
} from '../../basketball_5x5/constants';
import TeamSelect from './TeamSelect';

// Semantic ordering for stats - lower numbers appear first
const statSemanticOrder: Record<string, number> = {
  // Scoring stats
  [STAT_KEYS.FREE_THROWS_MADE]: 1,
  [STAT_KEYS.FREE_THROWS_MISSED]: 2,
  [STAT_KEYS.FIELD_GOALS_MADE]: 3,
  [STAT_KEYS.FIELD_GOALS_MISSED]: 4,
  [STAT_KEYS.THREE_POINT_FIELD_GOALS_MADE]: 5,
  [STAT_KEYS.THREE_POINT_FIELD_GOALS_MISSED]: 6,

  // Fouls
  [STAT_KEYS.FOULS_PERSONAL]: 7,
  [STAT_KEYS.FOULS_TECHNICAL]: 8,
  [STAT_KEYS.FOULS_UNSPORTSMANLIKE]: 9,
  [STAT_KEYS.FOULS_DISQUALIFYING]: 10,
  [STAT_KEYS.FOULS_DISQUALIFYING_FIGHTING]: 11,
  [STAT_KEYS.FOULS_GAME_DISQUALIFYING]: 12,

  // Rebounding stats
  [STAT_KEYS.REBOUNDS_OFFENSIVE]: 13,
  [STAT_KEYS.REBOUNDS_DEFENSIVE]: 14,

  // Playmaking stats
  [STAT_KEYS.ASSISTS]: 15,
  [STAT_KEYS.STEALS]: 16,
  [STAT_KEYS.BLOCKS]: 17,
  [STAT_KEYS.TURNOVERS]: 18,
};

interface UpdatePlayerStatFormProps {
  onChange: (updateFn: (prevPayload: any) => any) => void;
  gameState: GameState;
  initialPayload?: Record<string, any>;
}

const UpdatePlayerStatForm: React.FC<UpdatePlayerStatFormProps> = ({
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

  const manualStats = getManualPlayerStatsForView(
    gameState.view_settings_state.view,
  )
    .map((stat) => ({
      ...stat,
      semanticOrder: statSemanticOrder[stat.key] || 999, // Default to end if not found
    }))
    .sort((a, b) => a.semanticOrder - b.semanticOrder);

  const selectedTeam =
    selectedTeamType === 'home' ? gameState.home_team : gameState.away_team;
  const availablePlayers = selectedTeam?.players || [];

  // Check if the selected stat is a foul type
  const selectedStatId = initialPayload['stat-id'] || '';
  const isFoulStat = selectedStatId.startsWith('fouls_');

  const handleInputChange = (field: string, value: any) => {
    onChange((prevPayload: any) => ({
      ...prevPayload,
      [field]: value,
      operation: 'increment',
    }));
  };

  const handleMetadataChange = (metadataField: string, value: any) => {
    onChange((prevPayload: any) => ({
      ...prevPayload,
      metadata: {
        ...prevPayload.metadata,
        [metadataField]: value,
      },
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
        <TeamSelect
          selectedTeamType={selectedTeamType}
          onTeamChange={handleTeamChange}
          gameState={gameState}
          disabled={!!initialPayload['team-type']}
        />
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
                value={initialPayload['player-id'] || ''}
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
                value={initialPayload['stat-id'] || ''}
                onChange={(e) => handleInputChange('stat-id', e.target.value)}
              >
                <option value="">
                  {t(
                    'basketball.modals.eventLogs.payloadFields.playerStat.selectStatType',
                  )}
                </option>
                {manualStats.map((stat) => (
                  <option key={stat.key} value={stat.key}>
                    {t(stat.abbreviationTranslationKey)}
                  </option>
                ))}
              </select>
            </div>
          </div>
        </div>
      </div>

      {isFoulStat && (
        <div className="column is-4">
          <div className="field">
            <label className="label has-text-white-ter">
              {t(
                'basketball.modals.eventLogs.payloadFields.playerStat.freeThrowsAwarded',
              )}
            </label>
            <div className="control">
              <div className="select is-fullwidth">
                <select
                  value={initialPayload.metadata?.['free-throws-awarded'] || ''}
                  onChange={(e) =>
                    handleMetadataChange('free-throws-awarded', e.target.value)
                  }
                >
                  <option value="">
                    {t(
                      'basketball.modals.eventLogs.payloadFields.playerStat.noFreeThrows',
                    )}
                  </option>
                  <option value="1">+1</option>
                  <option value="2">+2</option>
                  <option value="3">+3</option>
                  <option value="C">C</option>
                </select>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default UpdatePlayerStatForm;
