import React, { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { GameState } from '../../../types';

interface UpdateCoachStatFormProps {
  onChange: (updateFn: (prevPayload: any) => any) => void;
  gameState: GameState;
  initialPayload?: Record<string, any>;
}

// Coach stats available for manual updates
const COACH_STATS = [
  {
    key: 'fouls_technical',
    labelTranslationKey: 'basketball.stats.labels.technicalFouls',
  },
  {
    key: 'fouls_disqualifying',
    labelTranslationKey: 'basketball.stats.labels.disqualifyingFouls',
  },
  {
    key: 'fouls_disqualifying_fighting',
    labelTranslationKey: 'basketball.stats.labels.disqualifyingFightingFouls',
  },
  {
    key: 'fouls_technical_bench',
    labelTranslationKey: 'basketball.stats.labels.technicalBenchFouls',
  },
  {
    key: 'fouls_technical_bench_disqualifying',
    labelTranslationKey:
      'basketball.stats.labels.technicalBenchDisqualifyingFouls',
  },
  {
    key: 'fouls_game_disqualifying',
    labelTranslationKey: 'basketball.stats.labels.gameDisqualifyingFouls',
  },
];

const UpdateCoachStatForm: React.FC<UpdateCoachStatFormProps> = ({
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

  const selectedTeam =
    selectedTeamType === 'home' ? gameState.home_team : gameState.away_team;
  const availableCoaches = selectedTeam?.coaches || [];

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
    handleInputChange('coach-id', '');
  };

  return (
    <div className="columns is-multiline">
      <div className="column is-4">
        <div className="field">
          <label className="label has-text-white-ter">
            {t('basketball.modals.eventLogs.payloadFields.coachStat.teamType')}
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
                    'basketball.modals.eventLogs.payloadFields.coachStat.selectTeam',
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
            {t('basketball.modals.eventLogs.payloadFields.coachStat.coachId')}
          </label>
          <div className="control">
            <div className="select is-fullwidth">
              <select
                disabled={!selectedTeamType}
                value={initialPayload['coach-id'] || ''}
                onChange={(e) => handleInputChange('coach-id', e.target.value)}
              >
                <option value="">
                  {selectedTeamType
                    ? t(
                        'basketball.modals.eventLogs.payloadFields.coachStat.selectCoach',
                      )
                    : t(
                        'basketball.modals.eventLogs.payloadFields.coachStat.selectTeamFirst',
                      )}
                </option>
                {availableCoaches.map((coach) => (
                  <option key={coach.id} value={coach.id}>
                    {coach.name}
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
            {t('basketball.modals.eventLogs.payloadFields.coachStat.statType')}
          </label>
          <div className="control">
            <div className="select is-fullwidth">
              <select
                value={initialPayload['stat-id'] || ''}
                onChange={(e) => handleInputChange('stat-id', e.target.value)}
              >
                <option value="">
                  {t(
                    'basketball.modals.eventLogs.payloadFields.coachStat.selectStatType',
                  )}
                </option>
                {COACH_STATS.map((stat) => (
                  <option key={stat.key} value={stat.key}>
                    {t(stat.labelTranslationKey)}
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
                'basketball.modals.eventLogs.payloadFields.coachStat.freeThrowsAwarded',
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
                      'basketball.modals.eventLogs.payloadFields.coachStat.noFreeThrows',
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

export default UpdateCoachStatForm;
