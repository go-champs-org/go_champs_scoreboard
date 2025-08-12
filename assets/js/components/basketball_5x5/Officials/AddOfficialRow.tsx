import React from 'react';
import { useTranslation } from 'react-i18next';
import { OFFICIAL_TYPES } from './constants';

interface AddOfficialRowProps {
  pushEvent: (event: string, data: any) => void;
  onConfirmAction: () => void;
}

function AddOfficialRow({ pushEvent, onConfirmAction }: AddOfficialRowProps) {
  const { t } = useTranslation();
  const [name, setName] = React.useState('');
  const [type, setType] = React.useState('scorer');
  const [licenseNumber, setLicenseNumber] = React.useState('');
  const [federation, setFederation] = React.useState('');

  const handleSubmit = () => {
    if (!name.trim()) {
      alert(t('basketball.officials.alerts.enterName'));
      return;
    }

    const payload = {
      name: name.trim(),
      type: type,
      license_number: licenseNumber.trim() || null,
      federation: federation.trim() || null,
    };

    pushEvent('add-official-to-game', payload);

    // Reset form
    setName('');
    setType('scorer');
    setLicenseNumber('');
    setFederation('');

    onConfirmAction();
  };

  const handleCancel = () => {
    // Reset form
    setName('');
    setType('scorer');
    setLicenseNumber('');
    setFederation('');

    onConfirmAction();
  };

  return (
    <tr>
      <td>
        <input
          className="input is-small"
          type="text"
          placeholder={t('basketball.officials.placeholders.officialName')}
          value={name}
          onChange={(e) => setName(e.target.value)}
          autoFocus
        />
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
            disabled={!name.trim()}
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
