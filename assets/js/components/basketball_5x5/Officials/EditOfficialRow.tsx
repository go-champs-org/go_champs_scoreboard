import React from 'react';
import { OfficialState } from '../../../types';

interface EditOfficialRowProps {
  key: string;
  official: OfficialState;
  pushEvent: (event: string, data: any) => void;
}

const OFFICIAL_TYPES = [
  { value: 'scorer', label: 'Scorer' },
  { value: 'assistant_scorer', label: 'Assistant Scorer' },
  { value: 'timekeeper', label: 'Timekeeper' },
  { value: 'shot_clock_operator', label: 'Shot Clock Operator' },
  { value: 'crew_chief', label: 'Crew Chief' },
  { value: 'umpire_1', label: 'Umpire 1' },
  { value: 'umpire_2', label: 'Umpire 2' },
];

function EditOfficialRow({ official, pushEvent }: EditOfficialRowProps) {
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
    if (!name.trim()) {
      alert('Please enter an official name');
      return;
    }

    const payload = {
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
    if (confirm(`Are you sure you want to remove ${official.name}?`)) {
      pushEvent('remove-official-from-game', { type: official.type });
    }
  };

  const getOfficialTypeLabel = (typeValue: string) => {
    const officialType = OFFICIAL_TYPES.find((t) => t.value === typeValue);
    return officialType ? officialType.label : typeValue;
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
              onChange={(e) => setType(e.target.value)}
              disabled // Disable type change during edit
            >
              {OFFICIAL_TYPES.map((officialType) => (
                <option key={officialType.value} value={officialType.value}>
                  {officialType.label}
                </option>
              ))}
            </select>
          </div>
          <p className="help is-info is-size-7">
            Type cannot be changed during edit
          </p>
        </td>
        <td>
          <input
            className="input is-small"
            type="text"
            value={licenseNumber}
            onChange={(e) => setLicenseNumber(e.target.value)}
            placeholder="License #"
          />
        </td>
        <td>
          <input
            className="input is-small"
            type="text"
            value={federation}
            onChange={(e) => setFederation(e.target.value)}
            placeholder="Federation"
          />
        </td>
        <td>
          <div className="buttons are-small">
            <button
              className="button is-success is-small"
              onClick={handleSave}
              disabled={!name.trim()}
            >
              <span className="icon is-small">
                <i className="fas fa-check"></i>
              </span>
            </button>
            <button className="button is-light is-small" onClick={handleCancel}>
              <span className="icon is-small">
                <i className="fas fa-times"></i>
              </span>
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
      <td></td>
    </tr>
  );
}

export default EditOfficialRow;
