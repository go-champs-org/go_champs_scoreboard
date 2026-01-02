import React from 'react';
import { useTranslation } from 'react-i18next';
import { OfficialState } from '../../../types';
import DoubleClickButton from '../../DoubleClickButton';
import { OFFICIAL_TYPES } from './constants';
import { selectOfficialLabelKey } from './selectors';

interface EditOfficialRowProps {
  key: string;
  official: OfficialState;
  pushEvent: (event: string, data: any) => void;
}

function EditOfficialRow({ official, pushEvent }: EditOfficialRowProps) {
  const { t } = useTranslation();
  const [isEditing, setIsEditing] = React.useState(false);
  const [name, setName] = React.useState(official.name);
  const [type, setType] = React.useState(official.type);
  const [licenseNumber, setLicenseNumber] = React.useState(
    official.license_number || '',
  );
  const [federation, setFederation] = React.useState(official.federation || '');

  const handleEdit = () => {
    setIsEditing(true);
    setName(official.name);
    setType(official.type);
    setLicenseNumber(official.license_number || '');
    setFederation(official.federation || '');
  };

  const handleSave = () => {
    const payload = {
      id: official.id,
      type: official.type, // Use original type for identification
      name: name.trim(),
      license_number: licenseNumber.trim() || null,
      federation: federation.trim() || null,
    };

    pushEvent('update-official-in-game', payload);
    setIsEditing(false);
  };

  const handleCancel = () => {
    setName(official.name);
    setType(official.type);
    setLicenseNumber(official.license_number || '');
    setFederation(official.federation || '');
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
          <input
            className="input is-small"
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            autoFocus
          />
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
              disabled={!name.trim()}
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
