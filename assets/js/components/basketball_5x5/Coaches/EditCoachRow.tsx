import React from 'react';
import { CoachState, TeamType } from '../../../types';
import DoubleClickButton from '../../DoubleClickButton';

interface StatInputProps {
  teamType: TeamType;
  coach: CoachState;
  statKey: string;
  pushEvent: (event: string, data: any) => void;
}

function StatInput({ coach, statKey, pushEvent, teamType }: StatInputProps) {
  const value = coach.stats_values[statKey];
  const [showButtons, setShowButtons] = React.useState(false);
  const containerRef = React.useRef<HTMLDivElement>(null);

  const handleClickOutside = (event: MouseEvent) => {
    if (
      containerRef.current &&
      !containerRef.current.contains(event.target as Node)
    ) {
      setShowButtons(false);
    }
  };

  React.useEffect(() => {
    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  const onMinusClick = () => {
    pushEvent('update-coach-stat', {
      ['stat-id']: statKey,
      operation: 'decrement',
      ['coach-id']: coach.id,
      ['team-type']: teamType,
    });
  };
  const onPlusClick = () => {
    pushEvent('update-coach-stat', {
      ['stat-id']: statKey,
      operation: 'increment',
      ['coach-id']: coach.id,
      ['team-type']: teamType,
    });
  };

  return (
    <div ref={containerRef} className="stat-input-container">
      <button
        className={`button is-small is-warning top ${
          showButtons ? 'show' : 'hide'
        }`}
        onClick={onMinusClick}
        disabled={coach.state !== 'available'}
      >
        -
      </button>
      <button
        className={`button is-small ${showButtons ? 'is-warning' : ''}`}
        onClick={() => setShowButtons(!showButtons)}
      >
        {value}
      </button>
      <button
        className={`button is-small is-warning bottom ${
          showButtons ? 'show' : 'hide'
        }`}
        onClick={onPlusClick}
        disabled={coach.state !== 'available'}
      >
        +
      </button>
    </div>
  );
}

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
        <StatInput
          coach={coach}
          statKey="fouls_personal"
          pushEvent={pushEvent}
          teamType={teamType}
        />
      </td>
      <td>
        <StatInput
          coach={coach}
          statKey="fouls_technical"
          pushEvent={pushEvent}
          teamType={teamType}
        />
      </td>
      <td>
        <StatInput
          coach={coach}
          statKey="fouls_unsportsmanlike"
          pushEvent={pushEvent}
          teamType={teamType}
        />
      </td>
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
