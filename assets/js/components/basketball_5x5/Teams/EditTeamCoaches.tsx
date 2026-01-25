import React from 'react';
import { useTranslation } from 'react-i18next';
import { TeamState, TeamType } from '../../../types';
import AddCoachRow from '../Coaches/AddCoachRow';
import EditCoachRow from '../Coaches/EditCoachRow';

interface EditTeamCoachesProps {
  team: TeamState;
  teamType: TeamType;
  showAddCoachRow: boolean;
  pushEvent: (event: string, data: any) => void;
  setShowAddCoachRow: (show: boolean) => void;
}

function EditTeamCoaches({
  team,
  teamType,
  showAddCoachRow,
  pushEvent,
  setShowAddCoachRow,
}: EditTeamCoachesProps) {
  const { t } = useTranslation();

  return (
    <div className="box">
      <div className="level">
        <div className="level-left">
          <div className="level-item">
            <h5 className="title is-6">
              {t('basketball.coaches.modal.title')}
            </h5>
          </div>
        </div>
        <div className="level-right">
          <div className="level-item">
            <button
              className="button is-info is-small"
              onClick={() => setShowAddCoachRow(true)}
            >
              {t('basketball.coaches.modal.addCoach')}
            </button>
          </div>
        </div>
      </div>

      <div className="table-container">
        <table className="table is-fullwidth">
          <thead>
            <tr>
              <th style={{ minWidth: '140px', maxWidth: '140px' }}>
                {t('basketball.coaches.modal.name')}
              </th>
              <th style={{ minWidth: '140px', maxWidth: '140px' }}>
                {t('basketball.coaches.modal.type')}
              </th>
              <th style={{ minWidth: '65px', maxWidth: '65px' }}>
                {t('basketball.stats.abbreviations.technicalFoulsShort')}
              </th>
              <th style={{ minWidth: '65px', maxWidth: '65px' }}>
                {t('basketball.stats.abbreviations.disqualifyingFoulsShort')}
              </th>
              <th style={{ minWidth: '65px', maxWidth: '65px' }}>
                {t(
                  'basketball.stats.abbreviations.disqualifyingFightingFoulsShort',
                )}
              </th>
              <th style={{ minWidth: '65px', maxWidth: '65px' }}>
                {t('basketball.stats.abbreviations.technicalBenchFoulsShort')}
              </th>
              <th style={{ minWidth: '65px', maxWidth: '65px' }}>
                {t(
                  'basketball.stats.abbreviations.technicalBenchDisqualifyingFoulsShort',
                )}
              </th>
              <th style={{ minWidth: '50px', maxWidth: '50px' }}>
                {t('basketball.coaches.modal.actions')}
              </th>
            </tr>
          </thead>
          <tbody>
            {showAddCoachRow && (
              <AddCoachRow
                teamType={teamType}
                pushEvent={pushEvent}
                onConfirmAction={() => setShowAddCoachRow(false)}
              />
            )}
            {team.coaches.map((coach) => (
              <EditCoachRow
                key={coach.id}
                coach={coach}
                teamType={teamType}
                pushEvent={pushEvent}
              />
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export default EditTeamCoaches;
