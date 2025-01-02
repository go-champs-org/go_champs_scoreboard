import React from 'react';

import { PlayerState, TeamType } from '../../../types';
import FormField from '../../FormField';
import DoubleClickButton from '../../DoubleClickButton';

interface StatInputProps {
  teamType: TeamType;
  player: PlayerState;
  statKey: string;
  pushEvent: (event: string, data: any) => void;
}

function StatInput({ player, statKey, pushEvent, teamType }: StatInputProps) {
  const value = player.stats_values[statKey];
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
    pushEvent('update-player-stat', {
      ['stat-id']: statKey,
      operation: 'decrement',
      ['player-id']: player.id,
      ['team-type']: teamType,
    });
  };
  const onPlusClick = () => {
    pushEvent('update-player-stat', {
      ['stat-id']: statKey,
      operation: 'increment',
      ['player-id']: player.id,
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
      >
        +
      </button>
    </div>
  );
}

interface EditPlayerRowProps {
  key: string;
  player: PlayerState;
  teamType: TeamType;
  pushEvent: (event: string, data: any) => void;
}

function EditPlayerRow({ player, teamType, pushEvent }: EditPlayerRowProps) {
  const onUpdatePlayerNumber = (value: string) => {
    pushEvent('update-player-in-team', {
      ['team-type']: teamType,
      player: { ...player, number: value },
    });
  };
  const onUpdatePlayerName = (value: string) => {
    pushEvent('update-player-in-team', {
      ['team-type']: teamType,
      player: { ...player, name: value },
    });
  };
  const onRemovePlayer = () => {
    pushEvent('remove-player-in-team', {
      ['team-type']: teamType,
      ['player-id']: player.id,
    });
  };
  return (
    <tr key={player.id}>
      <td>
        <FormField
          initialValue={player.number}
          onChange={onUpdatePlayerNumber}
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
          initialValue={player.name}
          onChange={onUpdatePlayerName}
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
        <StatInput
          player={player}
          statKey="free_throws_made"
          pushEvent={pushEvent}
          teamType={teamType}
        />
      </td>
      <td>
        <StatInput
          player={player}
          statKey="field_goals_made"
          pushEvent={pushEvent}
          teamType={teamType}
        />
      </td>
      <td>
        <StatInput
          player={player}
          statKey="three_point_field_goals_made"
          pushEvent={pushEvent}
          teamType={teamType}
        />
      </td>
      <td>
        <StatInput
          player={player}
          statKey="free_throws_missed"
          pushEvent={pushEvent}
          teamType={teamType}
        />
      </td>
      <td>
        <StatInput
          player={player}
          statKey="field_goals_missed"
          pushEvent={pushEvent}
          teamType={teamType}
        />
      </td>
      <td>
        <StatInput
          player={player}
          statKey="three_point_field_goals_missed"
          pushEvent={pushEvent}
          teamType={teamType}
        />
      </td>
      <td>
        <StatInput
          player={player}
          statKey="assists"
          pushEvent={pushEvent}
          teamType={teamType}
        />
      </td>
      <td>
        <StatInput
          player={player}
          statKey="blocks"
          pushEvent={pushEvent}
          teamType={teamType}
        />
      </td>
      <td>
        <StatInput
          player={player}
          statKey="steals"
          pushEvent={pushEvent}
          teamType={teamType}
        />
      </td>
      <td>
        <StatInput
          player={player}
          statKey="rebounds_defensive"
          pushEvent={pushEvent}
          teamType={teamType}
        />
      </td>
      <td>
        <StatInput
          player={player}
          statKey="rebounds_offensive"
          pushEvent={pushEvent}
          teamType={teamType}
        />
      </td>
      <td>
        <StatInput
          player={player}
          statKey="turnovers"
          pushEvent={pushEvent}
          teamType={teamType}
        />
      </td>
      <td>
        <StatInput
          player={player}
          statKey="fouls_personal"
          pushEvent={pushEvent}
          teamType={teamType}
        />
      </td>
      <td>
        <StatInput
          player={player}
          statKey="fouls_technical"
          pushEvent={pushEvent}
          teamType={teamType}
        />
      </td>
      <td>
        <StatInput
          player={player}
          statKey="fouls_flagrant"
          pushEvent={pushEvent}
          teamType={teamType}
        />
      </td>
      <td>
        <DoubleClickButton
          className="button is-warning is-small"
          onClick={onRemovePlayer}
        >
          &#10008;
        </DoubleClickButton>
      </td>
    </tr>
  );
}

export default EditPlayerRow;
