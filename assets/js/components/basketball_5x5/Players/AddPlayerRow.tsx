import React from 'react';
import { useTranslation } from 'react-i18next';
import { TeamType } from '../../../types';
import { ApiPlayer } from '../../../goChampsApiTypes';
import AutocompleteInput from '../../shared/form/AutocompleteInput';

interface AddPlayerRowProps {
  numberOfLeadingColumns: number;
  teamType: TeamType;
  pushEvent: (event: string, data: any) => void;
  onConfirmAction: () => void;
  teamPlayers: ApiPlayer[];
}

function AddPlayerRow({
  numberOfLeadingColumns,
  teamType,
  pushEvent,
  onConfirmAction,
  teamPlayers,
}: AddPlayerRowProps) {
  const { t } = useTranslation();
  const [number, setNumber] = React.useState('');
  const [name, setName] = React.useState('');
  const [selectedPlayer, setSelectedPlayer] = React.useState<ApiPlayer | null>(
    null,
  );
  const [manualEntryMode, setManualEntryMode] = React.useState(false);

  const handlePlayerSelect = (player: ApiPlayer | null) => {
    setSelectedPlayer(player);
    if (player) {
      // Auto-populate shirt number when player selected
      setNumber(player.shirt_number || '');
    }
  };

  const handleEnableManualEntry = () => {
    setManualEntryMode(true);
    setSelectedPlayer(null);
    setName('');
    setNumber('');
  };

  const handleDisableManualEntry = () => {
    setManualEntryMode(false);
    setSelectedPlayer(null);
    setName('');
    setNumber('');
  };

  const onCancelClick = () => {
    setNumber('');
    setName('');
    setManualEntryMode(false);
    setSelectedPlayer(null);
    onConfirmAction();
  };

  const onConfirmClick = () => {
    if (!manualEntryMode && !selectedPlayer) {
      alert(t('basketball.players.alerts.selectPlayer'));
      return;
    }

    if (!name.trim()) {
      alert(t('basketball.players.alerts.enterName'));
      return;
    }

    if (!number.trim()) {
      alert(t('basketball.players.alerts.enterNumber'));
      return;
    }

    const payload = {
      ['team-type']: teamType,
      number: number.trim(),
      name: name.trim(),
      // Include player ID if selected from dropdown
      ...(selectedPlayer && { id: selectedPlayer.id }),
    };

    pushEvent('add-player-to-team', payload);

    // Reset form
    setNumber('');
    setName('');
    setManualEntryMode(false);
    setSelectedPlayer(null);

    onConfirmAction();
  };

  return (
    <tr>
      {[...Array(numberOfLeadingColumns)].map((_, index) => (
        <td key={index}></td>
      ))}
      <td>
        <input
          className="input is-small"
          type="text"
          placeholder={t('basketball.players.placeholders.number')}
          value={number}
          onChange={(e) => setNumber(e.target.value)}
        />
      </td>
      <td>
        {manualEntryMode ? (
          <div className="field has-addons">
            <div className="control is-expanded">
              <input
                className="input is-small"
                type="text"
                placeholder={t('basketball.players.placeholders.playerName')}
                value={name}
                onChange={(e) => setName(e.target.value)}
                autoFocus
              />
            </div>
            <div className="control">
              <button
                className="button is-small is-info"
                onClick={handleDisableManualEntry}
                title={t('basketball.players.buttons.selectFromList')}
              >
                &#8634;
              </button>
            </div>
          </div>
        ) : (
          <div className="field has-addons">
            <div className="control is-expanded">
              <AutocompleteInput
                value={name}
                onChange={setName}
                onSelect={handlePlayerSelect}
                items={teamPlayers}
                getItemText={(player) => player.name}
                getItemKey={(player) => player.id}
                getItemSubtitle={(player) => {
                  const parts = [];
                  if (player.shirt_number) {
                    parts.push(player.shirt_number);
                  }
                  if (player.shirt_name) {
                    parts.push(player.shirt_name);
                  }
                  if (player.registration_response?.response?.email) {
                    parts.push(player.registration_response.response.email);
                  }
                  return parts.length > 0 ? parts.join(' - ') : '';
                }}
                getSearchableText={(player) => {
                  const searchParts = [player.name];
                  if (player.registration_response?.response?.email) {
                    searchParts.push(
                      player.registration_response.response.email,
                    );
                  }
                  return searchParts.join(' ');
                }}
                placeholder={t('basketball.players.placeholders.playerName')}
                autoFocus
              />
            </div>
            <div className="control">
              <button
                className="button is-small is-warning"
                onClick={handleEnableManualEntry}
                title={t('basketball.players.buttons.createNew')}
              >
                +
              </button>
            </div>
          </div>
        )}
      </td>

      <td>
        <button
          className="button is-small is-success"
          onClick={onConfirmClick}
          disabled={
            !number.trim() ||
            !name.trim() ||
            (!manualEntryMode && !selectedPlayer)
          }
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
