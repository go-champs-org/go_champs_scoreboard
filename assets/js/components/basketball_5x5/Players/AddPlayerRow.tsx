import React from 'react';

import { TeamType } from '../../../types';
import FormField from '../../FormField';

interface AddPlayerRowProps {
  numberOfLeadingColumns: number;
  teamType: TeamType;
  pushEvent: (event: string, data: any) => void;
  onConfirmAction: () => void;
}

function AddPlayerRow({
  numberOfLeadingColumns,
  teamType,
  pushEvent,
  onConfirmAction,
}: AddPlayerRowProps) {
  const [number, setNumber] = React.useState('');
  const [name, setName] = React.useState('');
  const onCancelClick = () => {
    setNumber('');
    setName('');
    onConfirmAction();
  };
  const onConfirmClick = () => {
    pushEvent('add-player-to-team', {
      ['team-type']: teamType,
      number,
      name,
    });
    onConfirmAction();
  };

  return (
    <tr>
      {[...Array(numberOfLeadingColumns)].map((_, index) => (
        <td key={index}></td>
      ))}
      <td>
        <FormField
          initialValue={''}
          onChange={(value) => setNumber(value)}
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
        <button
          className="button is-small is-success"
          onClick={onConfirmClick}
          disabled={!number || !name}
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

export default AddPlayerRow;
