import React from 'react';

import { PlayerState, TeamType } from '../../../types';
import FormField from '../../FormField';
import CheckboxFormField from '../../CheckboxFormField';
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
        disabled={player.state === 'not_available'}
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
        disabled={player.state === 'not_available'}
      >
        +
      </button>
    </div>
  );
}

function NameCell({ player }: { player: PlayerState }) {
  const CellContent = () => (
    <div
      style={{
        maxWidth: '140px',
        overflow: 'hidden',
        textOverflow: 'ellipsis',
        textWrap: 'nowrap',
        verticalAlign: 'middle',
      }}
    >
      {player.name}
    </div>
  );
  return player.state === 'not_available' ? (
    <div className="has-tooltip" data-tooltip="Player is not available">
      <CellContent />
    </div>
  ) : (
    <CellContent />
  );
}

interface EditPlayerRowProps {
  rowNumber: number;
  key: string;
  player: PlayerState;
  teamType: TeamType;
  pushEvent: (event: string, data: any) => void;
  highlighted?: boolean;
}

export function BasicEditPlayerRow({
  rowNumber,
  player,
  teamType,
  pushEvent,
  highlighted = false,
}: EditPlayerRowProps) {
  const onUpdatePlayerNumber = (value: string) => {
    pushEvent('update-player-in-team', {
      ['team-type']: teamType,
      player: { ...player, number: value },
    });
  };
  const onRemovePlayer = () => {
    pushEvent('remove-player-in-team', {
      ['team-type']: teamType,
      ['player-id']: player.id,
    });
  };
  return (
    <tr
      key={player.id}
      className={`edit-player-row${highlighted ? ' highlighted' : ''}`}
    >
      <td>{rowNumber}</td>
      <td>
        <DoubleClickButton
          className="button is-warning is-small is-fullwidth"
          onClick={onRemovePlayer}
          disabled={player.state === 'not_available'}
        >
          &#10008;
        </DoubleClickButton>
      </td>
      <td
        style={{
          maxWidth: '30px',
          width: '30px',
        }}
      >
        <FormField
          initialValue={player.number}
          onChange={onUpdatePlayerNumber}
          render={(value, onChange) => (
            <input
              className="input is-small"
              type="text"
              value={value}
              placeholder="00"
              onChange={onChange}
              disabled={player.state === 'not_available'}
            />
          )}
        />
      </td>
      <td
        style={{
          verticalAlign: 'middle',
        }}
      >
        <NameCell player={player} />
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
          statKey="rebounds_defensive"
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
    </tr>
  );
}

function MediumEditPlayerRow({
  rowNumber,
  player,
  teamType,
  pushEvent,
  highlighted = false,
}: EditPlayerRowProps) {
  const onUpdatePlayerNumber = (value: string) => {
    pushEvent('update-player-in-team', {
      ['team-type']: teamType,
      player: { ...player, number: value },
    });
  };
  const onUpdateLicenseNumber = (value: string) => {
    pushEvent('update-player-in-team', {
      ['team-type']: teamType,
      player: { ...player, license_number: value },
    });
  };
  const onUpdateIsCaptain = (value: boolean) => {
    pushEvent('update-player-in-team', {
      ['team-type']: teamType,
      player: { ...player, is_captain: value },
    });
  };
  const onRemovePlayer = () => {
    pushEvent('remove-player-in-team', {
      ['team-type']: teamType,
      ['player-id']: player.id,
    });
  };
  return (
    <tr
      key={player.id}
      className={`edit-player-row${highlighted ? ' highlighted' : ''}`}
    >
      <td>{rowNumber}</td>
      <td>
        <DoubleClickButton
          className="button is-warning is-small is-fullwidth"
          onClick={onRemovePlayer}
          disabled={player.state === 'not_available'}
        >
          &#10008;
        </DoubleClickButton>
      </td>
      <td>
        <FormField
          initialValue={player.license_number}
          onChange={onUpdateLicenseNumber}
          render={(value, onChange) => (
            <input
              className="input is-small"
              type="text"
              value={value}
              placeholder="AB12"
              onChange={onChange}
              disabled={player.state === 'not_available'}
            />
          )}
        />
      </td>
      <td>
        <FormField
          initialValue={player.number}
          onChange={onUpdatePlayerNumber}
          render={(value, onChange) => (
            <input
              className="input is-small"
              type="text"
              value={value}
              placeholder="00"
              onChange={onChange}
              disabled={player.state === 'not_available'}
            />
          )}
        />
      </td>
      <td
        style={{
          verticalAlign: 'middle',
        }}
      >
        <NameCell player={player} />
      </td>
      <td
        style={{
          verticalAlign: 'middle',
        }}
      >
        <CheckboxFormField
          initialValue={player.is_captain}
          onChange={onUpdateIsCaptain}
          disabled={player.state === 'not_available'}
          className="captain-checkbox"
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
          statKey="fouls_unsportsmanlike"
          pushEvent={pushEvent}
          teamType={teamType}
        />
      </td>
    </tr>
  );
}

export default MediumEditPlayerRow;
