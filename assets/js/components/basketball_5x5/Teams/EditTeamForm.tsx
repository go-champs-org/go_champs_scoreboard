import React from 'react';
import { useTranslation } from 'react-i18next';
import { TeamState, TeamType } from '../../../types';
import debounce from '../../../debounce';

interface EditTeamFormProps {
  team: TeamState;
  teamType: TeamType;
  pushEvent: (event: string, data: any) => void;
}

function EditTeamForm({ team, teamType, pushEvent }: EditTeamFormProps) {
  const { t } = useTranslation();
  const defaultColor = '#000000';
  const [localColor, setLocalColor] = React.useState(
    team.primary_color || defaultColor,
  );
  const [localTriCode, setLocalTriCode] = React.useState(team.tri_code || '');
  const [hasCustomColor, setHasCustomColor] = React.useState(
    !!team.primary_color,
  );

  React.useEffect(() => {
    setLocalColor(team.primary_color || defaultColor);
    setHasCustomColor(!!team.primary_color);
  }, [team.primary_color]);

  React.useEffect(() => {
    setLocalTriCode(team.tri_code || '');
  }, [team.tri_code]);

  const debouncedPushEvent = React.useMemo(
    () =>
      debounce((field: string, value: string | null) => {
        pushEvent('update-team-metadata', {
          'team-type': teamType,
          [field]: value,
        });
      }, 500),
    [pushEvent, teamType],
  );

  const handleColorChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const newColor = event.target.value;
    setLocalColor(newColor);
    setHasCustomColor(true);
    debouncedPushEvent('primary_color', newColor);
  };

  const handleColorRemove = () => {
    setLocalColor(defaultColor);
    setHasCustomColor(false);
    debouncedPushEvent('primary_color', null);
  };

  const handleTriCodeChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const newTriCode = event.target.value.toUpperCase().substring(0, 3);
    setLocalTriCode(newTriCode);
    debouncedPushEvent('tri_code', newTriCode);
  };

  return (
    <div className="box">
      <div className="columns is-multiline">
        <div className="column is-4">
          <div className="field">
            <label className="label">{t('basketball.teams.modal.name')}</label>
            <div className="control">
              <input type="text" className="input" value={team.name} disabled />
            </div>
            <p className="help">{t('basketball.teams.modal.nameHelp')}</p>
          </div>
        </div>

        <div className="column is-4">
          <div className="field">
            <label className="label">
              {t('basketball.teams.modal.triCode')}
            </label>
            <div className="control">
              <input
                type="text"
                className="input"
                value={localTriCode}
                onChange={handleTriCodeChange}
                placeholder="ABC"
                maxLength={3}
              />
            </div>
            <p className="help">{t('basketball.teams.modal.triCodeHelp')}</p>
          </div>
        </div>

        <div className="column is-4">
          <div className="field">
            <label className="label">
              {t('basketball.teams.modal.primaryColor')}
            </label>
            <div className="control">
              <div className="field has-addons">
                <div className="control">
                  <input
                    type="color"
                    className="input"
                    value={localColor}
                    onChange={handleColorChange}
                    style={{ width: '100px', height: '40px' }}
                  />
                </div>
                <div className="control">
                  <button
                    type="button"
                    className="button"
                    onClick={handleColorRemove}
                    disabled={!hasCustomColor}
                    style={{ height: '40px' }}
                    title={t('basketball.teams.modal.removeColor')}
                  >
                    ✕
                  </button>
                </div>
              </div>
            </div>
            <p className="help">
              {hasCustomColor
                ? t('basketball.teams.modal.primaryColorHelp')
                : t('basketball.teams.modal.defaultColorHelp')}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

export default EditTeamForm;
