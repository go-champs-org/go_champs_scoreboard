import React from 'react';

interface AddOfficialRowProps {
  pushEvent: (event: string, data: any) => void;
  onConfirmAction: () => void;
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

function AddOfficialRow({ pushEvent, onConfirmAction }: AddOfficialRowProps) {
  const [name, setName] = React.useState('');
  const [type, setType] = React.useState('scorer');
  const [licenseNumber, setLicenseNumber] = React.useState('');
  const [federation, setFederation] = React.useState('');

  const handleSubmit = () => {
    if (!name.trim()) {
      alert('Please enter an official name');
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
          placeholder="Official name"
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
                {officialType.label}
              </option>
            ))}
          </select>
        </div>
      </td>
      <td>
        <input
          className="input is-small"
          type="text"
          placeholder="License #"
          value={licenseNumber}
          onChange={(e) => setLicenseNumber(e.target.value)}
        />
      </td>
      <td>
        <input
          className="input is-small"
          type="text"
          placeholder="Federation"
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
