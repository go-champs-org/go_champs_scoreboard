import React from 'react';
import { CoachState, TeamType } from '../../../types';
import DoubleClickButton from '../../DoubleClickButton';

interface EditCoachRowProps {
  key: string;
  coach: CoachState;
  teamType: TeamType;
  pushEvent: (event: string, data: any) => void;
}

function EditCoachRow({ coach, teamType, pushEvent }: EditCoachRowProps) {
  const onRemoveCoach = () => {
    pushEvent('remove-coach-in-team', {
      ['team-type']: teamType,
      ['coach-id']: coach.id,
    });
  };
  return (
    <tr key={coach.id}>
      <td
        style={{
          verticalAlign: 'middle',
        }}
      >
        {coach.name}
      </td>
      <td>{coach.type}</td>
      <td>
        <DoubleClickButton
          className="button is-warning is-small"
          onClick={onRemoveCoach}
        >
          &#10008;
        </DoubleClickButton>
      </td>
    </tr>
  );
}

export default EditCoachRow;
