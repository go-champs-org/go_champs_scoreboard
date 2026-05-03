import React from 'react';
import { useTranslation } from 'react-i18next';
import { TeamType, PlayerState } from '../../../types';
import { ApiPlayer } from '../../../goChampsApiTypes';

interface AddPlayerPanelProps {
  apiPlayers: ApiPlayer[];
  currentPlayers: PlayerState[];
  teamType: TeamType;
  pushEvent: (event: string, data: any) => void;
  onClose: () => void;
}

function AddPlayerPanel({
  apiPlayers,
  currentPlayers,
  teamType,
  pushEvent,
  onClose,
}: AddPlayerPanelProps) {
  const { t } = useTranslation();
  const [searchText, setSearchText] = React.useState('');
  const [number, setNumber] = React.useState('');

  const currentPlayerIds = new Set(currentPlayers.map((p) => p.id));

  const filteredAvailable = apiPlayers.filter(
    (p) =>
      !currentPlayerIds.has(p.id) &&
      p.name.toLowerCase().includes(searchText.toLowerCase()),
  );

  const filteredAlreadyInTeam =
    searchText.trim().length > 0
      ? currentPlayers.filter((p) =>
          p.name.toLowerCase().includes(searchText.toLowerCase()),
        )
      : [];

  const showManualEntry =
    searchText.trim().length > 0 && filteredAvailable.length === 0;

  const handleAddApiPlayer = (player: ApiPlayer) => {
    pushEvent('add-player-to-team', {
      'team-type': teamType,
      id: player.id,
      name: player.name,
      number: player.shirt_number || '',
    });
  };

  const handleCreateManual = () => {
    if (!number.trim()) return;
    pushEvent('add-player-to-team', {
      'team-type': teamType,
      name: searchText.trim(),
      number: number.trim(),
    });
    setNumber('');
    setSearchText('');
  };

  return (
    <div className="add-player-panel box">
      <div className="field">
        <div className="control">
          <input
            className="input"
            type="text"
            autoFocus
            placeholder={t('basketball.players.addPanel.searchPlaceholder')}
            value={searchText}
            onChange={(e) => setSearchText(e.target.value)}
          />
        </div>
      </div>

      {filteredAvailable.length > 0 && (
        <table className="table is-fullwidth is-striped is-narrow">
          <tbody>
            {filteredAvailable.map((player) => (
              <tr key={player.id}>
                <td style={{ width: '80px' }}>{player.shirt_number || '—'}</td>
                <td>{player.name}</td>
                <td style={{ width: '90px', textAlign: 'right' }}>
                  <button
                    className="button is-success is-small"
                    onClick={() => handleAddApiPlayer(player)}
                  >
                    {t('basketball.players.addPanel.add')}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {filteredAlreadyInTeam.length > 0 && (
        <table className="table is-fullwidth is-narrow">
          <tbody>
            {filteredAlreadyInTeam.map((player) => (
              <tr key={player.id}>
                <td style={{ width: '80px' }}>{player.number || '—'}</td>
                <td>{player.name}</td>
                <td style={{ width: '170px', textAlign: 'right' }}>
                  <span className="tag is-info is-light mr-1">
                    {t('basketball.players.addPanel.inTeam')}
                  </span>
                  <button className="button is-small" disabled>
                    {t('basketball.players.addPanel.add')}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {showManualEntry && (
        <div className="field is-grouped mt-3">
          <div className="control">
            <input
              className="input"
              type="text"
              placeholder={t('basketball.players.addPanel.numberPlaceholder')}
              value={number}
              onChange={(e) => setNumber(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && handleCreateManual()}
              style={{ width: '100px' }}
            />
          </div>
          <div className="control">
            <button
              className="button is-success"
              disabled={!number.trim()}
              onClick={handleCreateManual}
            >
              {t('basketball.players.addPanel.create')}
            </button>
          </div>
          <p className="control is-size-7 is-align-self-center has-text-grey">
            {t('basketball.players.addPanel.newPlayerHint')}
          </p>
        </div>
      )}

      <div className="mt-3">
        <button className="button is-light" onClick={onClose}>
          {t('basketball.players.addPanel.back')}
        </button>
      </div>
    </div>
  );
}

export default AddPlayerPanel;
