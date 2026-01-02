import React from 'react';
import { useTranslation } from 'react-i18next';
import FormField from '../../FormField';
import { TeamType } from '../../../types';
import { COACH_TYPE_LABELS, COACH_TYPES } from './constants';

interface AddCoachRowProps {
  teamType: TeamType;
  pushEvent: (event: string, data: any) => void;
  onConfirmAction: () => void;
}

function AddCoachRow({
  teamType,
  pushEvent,
  onConfirmAction,
}: AddCoachRowProps) {
  const { t } = useTranslation();
  const [name, setName] = React.useState('');
  const [type, setType] = React.useState<'head_coach' | 'assistant_coach'>(
    'head_coach',
  );

  const onCancelClick = () => {
    setType('head_coach');
    setName('');
    onConfirmAction();
  };

  const onConfirmClick = () => {
    pushEvent('add-coach-to-team', {
      ['team-type']: teamType,
      name,
      type,
    });
    onConfirmAction();
  };

  return (
    <tr>
      <td>
        <FormField
          initialValue={''}
          onChange={(value) => setName(value)}
          render={(value, onChange) => (
            <input
              className="input is-small"
              type="text"
              value={value}
              onChange={onChange}
            />
          )}
        />
      </td>
      <td>
        <FormField
          initialValue={'head_coach'}
          onChange={(value) =>
            setType(value as 'head_coach' | 'assistant_coach')
          }
          render={(value, onChange) => (
            <div className="select is-small">
              <select value={value} onChange={onChange}>
                <option value="head_coach">
                  {t(COACH_TYPE_LABELS[COACH_TYPES.HEAD_COACH])}
                </option>
                <option value="assistant_coach">
                  {t(COACH_TYPE_LABELS[COACH_TYPES.ASSISTANT_COACH])}
                </option>
              </select>
            </div>
          )}
        />
      </td>
      <td>
        <button
          className="button is-small is-success"
          onClick={onConfirmClick}
          disabled={!name || !type}
        >
          &#10003;
        </button>
      </td>
      <td>
        <button className="button is-small is-danger" onClick={onCancelClick}>
          &#10008;
        </button>
      </td>
    </tr>
  );
}

export default AddCoachRow;
