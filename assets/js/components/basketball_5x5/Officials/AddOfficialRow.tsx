import React from 'react';
import { useTranslation } from 'react-i18next';
import { ApiOfficial } from '../../../goChampsApiTypes';
import AutocompleteInput from '../../shared/form/AutocompleteInput';
import { OFFICIAL_TYPES } from './constants';

interface AddOfficialRowProps {
  pushEvent: (event: string, data: any) => void;
  onConfirmAction: () => void;
  tournamentOfficials: ApiOfficial[];
}

function AddOfficialRow({
  pushEvent,
  onConfirmAction,
  tournamentOfficials,
}: AddOfficialRowProps) {
  const { t } = useTranslation();
  const [name, setName] = React.useState('');
  const [type, setType] = React.useState('scorer');
  const [licenseNumber, setLicenseNumber] = React.useState('');
  const [federation, setFederation] = React.useState('');
  const [selectedOfficial, setSelectedOfficial] =
    React.useState<ApiOfficial | null>(null);
  const [manualEntryMode, setManualEntryMode] = React.useState(false);

  const handleOfficialSelect = (official: ApiOfficial | null) => {
    setSelectedOfficial(official);
    if (official) {
      // Auto-populate license number if available
      setLicenseNumber(official.license_number || '');
    }
  };

  const handleEnableManualEntry = () => {
    setManualEntryMode(true);
    setSelectedOfficial(null);
    setName('');
    setLicenseNumber('');
  };

  const handleDisableManualEntry = () => {
    setManualEntryMode(false);
    setSelectedOfficial(null);
    setName('');
    setLicenseNumber('');
  };

  const handleSubmit = () => {
    if (!manualEntryMode && !selectedOfficial) {
      alert(t('basketball.officials.alerts.selectOfficial'));
      return;
    }

    if (!name.trim()) {
      alert(t('basketball.officials.alerts.enterName'));
      return;
    }

    const payload = {
      name: name.trim(),
      type: type,
      license_number: licenseNumber.trim() || null,
      federation: federation.trim() || null,
      // Include official ID if selected from dropdown
      ...(selectedOfficial && { id: selectedOfficial.id }),
    };

    pushEvent('add-official-to-game', payload);

    // Reset form
    setName('');
    setType('scorer');
    setLicenseNumber('');
    setFederation('');
    setManualEntryMode(false);
    setSelectedOfficial(null);

    onConfirmAction();
  };

  const handleCancel = () => {
    // Reset form
    setName('');
    setType('scorer');
    setLicenseNumber('');
    setFederation('');
    setSelectedOfficial(null);
    setManualEntryMode(false);

    onConfirmAction();
  };

  return (
    <tr>
      <td>
        {manualEntryMode ? (
          <div className="field has-addons">
            <div className="control is-expanded">
              <input
                className="input is-small"
                type="text"
                placeholder={t(
                  'basketball.officials.placeholders.officialName',
                )}
                value={name}
                onChange={(e) => setName(e.target.value)}
                autoFocus
              />
            </div>
            <div className="control">
              <button
                className="button is-small is-info"
                onClick={handleDisableManualEntry}
                title={t('basketball.officials.buttons.selectFromList')}
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
                onSelect={handleOfficialSelect}
                items={tournamentOfficials}
                getItemText={(official) => official.name}
                getItemKey={(official) => official.id}
                getItemSubtitle={(official) => official.license_number}
                placeholder={t(
                  'basketball.officials.placeholders.officialName',
                )}
                autoFocus
              />
            </div>
            <div className="control">
              <button
                className="button is-small is-warning"
                onClick={handleEnableManualEntry}
                title={t('basketball.officials.buttons.createNew')}
              >
                +
              </button>
            </div>
          </div>
        )}
      </td>
      <td>
        <div className="select is-small is-fullwidth">
          <select value={type} onChange={(e) => setType(e.target.value)}>
            {OFFICIAL_TYPES.map((officialType) => (
              <option key={officialType.value} value={officialType.value}>
                {t(officialType.labelKey)}
              </option>
            ))}
          </select>
        </div>
      </td>
      <td>
        <input
          className="input is-small"
          type="text"
          placeholder={t('basketball.officials.placeholders.licenseNumber')}
          value={licenseNumber}
          onChange={(e) => setLicenseNumber(e.target.value)}
        />
      </td>
      <td>
        <input
          className="input is-small"
          type="text"
          placeholder={t('basketball.officials.placeholders.federation')}
          value={federation}
          onChange={(e) => setFederation(e.target.value)}
        />
      </td>
      <td>
        <div className="buttons are-small">
          <button
            className="button is-success is-small"
            onClick={handleSubmit}
            disabled={!name.trim() || (!manualEntryMode && !selectedOfficial)}
          >
            &#10003;
          </button>
        </div>
      </td>
      <td>
        <button className="button is-danger is-small" onClick={handleCancel}>
          &#10008;
        </button>
      </td>
    </tr>
  );
}

export default AddOfficialRow;
