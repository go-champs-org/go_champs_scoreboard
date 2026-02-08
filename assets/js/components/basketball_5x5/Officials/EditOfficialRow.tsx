import React from 'react';
import { useTranslation } from 'react-i18next';
import { OfficialState } from '../../../types';
import { ApiOfficial } from '../../../goChampsApiTypes';
import AutocompleteInput from '../../shared/form/AutocompleteInput';
import DoubleClickButton from '../../DoubleClickButton';
import { OFFICIAL_TYPES } from './constants';
import { selectOfficialLabelKey } from './selectors';

interface EditOfficialRowProps {
  key: string;
  official: OfficialState;
  pushEvent: (event: string, data: any) => void;
  tournamentOfficials: ApiOfficial[];
}

function EditOfficialRow({
  official,
  pushEvent,
  tournamentOfficials,
}: EditOfficialRowProps) {
  const { t } = useTranslation();
  const [isEditing, setIsEditing] = React.useState(false);
  const [name, setName] = React.useState(official.name);
  const [type, setType] = React.useState(official.type);
  const [licenseNumber, setLicenseNumber] = React.useState(
    official.license_number || '',
  );
  const [federation, setFederation] = React.useState(official.federation || '');
  const [selectedOfficial, setSelectedOfficial] =
    React.useState<ApiOfficial | null>(null);
  const [manualEntryMode, setManualEntryMode] = React.useState(false);

  const handleOfficialSelect = (selectedOff: ApiOfficial | null) => {
    setSelectedOfficial(selectedOff);
    if (selectedOff) {
      // Auto-populate license number if available
      setLicenseNumber(selectedOff.license_number || '');
    }
  };

  const handleEnableManualEntry = () => {
    setManualEntryMode(true);
    setSelectedOfficial(null);
  };

  const handleDisableManualEntry = () => {
    setManualEntryMode(false);
    setSelectedOfficial(null);
    setName(official.name);
    setLicenseNumber(official.license_number || '');
  };

  const handleEdit = () => {
    setIsEditing(true);
    setName(official.name);
    setType(official.type);
    setLicenseNumber(official.license_number || '');
    setFederation(official.federation || '');
    setSelectedOfficial(null);
    setManualEntryMode(false);
  };

  const handleSave = () => {
    if (!manualEntryMode && !selectedOfficial && name !== official.name) {
      alert(t('basketball.officials.alerts.selectOfficial'));
      return;
    }

    const payload = {
      id: official.id, // Current official ID
      type: official.type, // Use original type for identification
      name: name.trim(),
      license_number: licenseNumber.trim() || null,
      federation: federation.trim() || null,
      // Include new ID if selected from dropdown
      ...(selectedOfficial && { new_id: selectedOfficial.id }),
    };

    pushEvent('update-official-in-game', payload);
    setIsEditing(false);
  };

  const handleCancel = () => {
    setName(official.name);
    setType(official.type);
    setLicenseNumber(official.license_number || '');
    setFederation(official.federation || '');
    setSelectedOfficial(null);
    setManualEntryMode(false);
    setIsEditing(false);
  };

  const handleRemove = () => {
    pushEvent('remove-official-in-game', { ['id']: official.id });
  };

  const getOfficialTypeLabel = (typeValue: string) => {
    const officialLabelKey = selectOfficialLabelKey(typeValue);
    return officialLabelKey ? t(officialLabelKey) : typeValue;
  };

  if (isEditing) {
    return (
      <tr>
        <td>
          {manualEntryMode ? (
            <div className="field has-addons">
              <div className="control is-expanded">
                <input
                  className="input is-small"
                  type="text"
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
            <select
              value={type}
              onChange={(e) => setType(e.target.value as any)}
              disabled // Disable type change during edit
            >
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
            value={licenseNumber}
            onChange={(e) => setLicenseNumber(e.target.value)}
            placeholder={t('basketball.officials.placeholders.licenseNumber')}
          />
        </td>
        <td>
          <input
            className="input is-small"
            type="text"
            value={federation}
            onChange={(e) => setFederation(e.target.value)}
            placeholder={t('basketball.officials.placeholders.federation')}
          />
        </td>
        <td>
          <div className="buttons are-small">
            <button
              className="button is-success is-small"
              onClick={handleSave}
              disabled={
                !name.trim() ||
                (!manualEntryMode &&
                  !selectedOfficial &&
                  name !== official.name)
              }
            >
              &#10004;
            </button>
            <button className="button is-light is-small" onClick={handleCancel}>
              &#10008;
            </button>
          </div>
        </td>
      </tr>
    );
  }

  return (
    <tr>
      <td>{official.name}</td>
      <td>
        <span className="tag is-info is-light">
          {getOfficialTypeLabel(official.type)}
        </span>
      </td>
      <td>{official.license_number || '-'}</td>
      <td>{official.federation || '-'}</td>
      <td>
        <button className="button is-primary is-small" onClick={handleEdit}>
          &#9998;
        </button>
      </td>
      <td>
        <DoubleClickButton
          className="button is-warning is-small"
          onClick={handleRemove}
        >
          &#10008;
        </DoubleClickButton>
      </td>
    </tr>
  );
}

export default EditOfficialRow;
