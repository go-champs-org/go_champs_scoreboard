import React from 'react';

interface DateTimeInputProps {
  value?: string | null;
  onChange: (dateTime: string | null) => void;
  dateLabel?: string;
  timeLabel?: string;
  className?: string;
  disabled?: boolean;
}

function DateTimeInput({
  value,
  onChange,
  dateLabel = 'Date',
  timeLabel = 'Time',
  className = '',
  disabled = false,
}: DateTimeInputProps) {
  // Parse the ISO datetime string into date and time parts
  const parseDateTime = (isoString: string | null) => {
    if (!isoString) {
      return { date: '', time: '' };
    }

    try {
      const dateObj = new Date(isoString);
      if (isNaN(dateObj.getTime())) {
        return { date: '', time: '' };
      }

      // Format date as YYYY-MM-DD
      const date = dateObj.toISOString().split('T')[0];

      // Format time as HH:MM (local time)
      const time = dateObj.toTimeString().slice(0, 5);

      return { date, time };
    } catch {
      return { date: '', time: '' };
    }
  };

  // Combine date and time into ISO string
  const combineDateTime = (date: string, time: string) => {
    if (!date && !time) {
      return null;
    }

    if (!date || !time) {
      // If only one field is provided, don't create an invalid datetime
      return null;
    }

    try {
      const dateTimeString = `${date}T${time}:00`;
      const dateObj = new Date(dateTimeString);

      if (isNaN(dateObj.getTime())) {
        return null;
      }

      return dateObj.toISOString();
    } catch {
      return null;
    }
  };

  const { date, time } = parseDateTime(value);

  const handleDateChange = (newDate: string) => {
    const newDateTime = combineDateTime(newDate, time);
    onChange(newDateTime);
  };

  const handleTimeChange = (newTime: string) => {
    const newDateTime = combineDateTime(date, newTime);
    onChange(newDateTime);
  };

  return (
    <div className={`datetime-input ${className}`}>
      <div className="field is-grouped">
        <div className="control is-expanded">
          <label className="label is-small">{dateLabel}</label>
          <input
            className="input"
            type="date"
            value={date}
            onChange={(e) => handleDateChange(e.target.value)}
            disabled={disabled}
          />
        </div>
        <div className="control is-expanded">
          <label className="label is-small">{timeLabel}</label>
          <input
            className="input"
            type="time"
            value={time}
            onChange={(e) => handleTimeChange(e.target.value)}
            disabled={disabled}
          />
        </div>
      </div>
    </div>
  );
}

export default DateTimeInput;
