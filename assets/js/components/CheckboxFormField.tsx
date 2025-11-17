import React from 'react';

interface CheckboxFormFieldProps {
  initialValue: boolean;
  onChange: (value: boolean) => void;
  render?: (
    value: boolean,
    onChange: (checked: boolean) => void,
  ) => React.ReactNode;
  label?: string;
  disabled?: boolean;
  className?: string;
}

function CheckboxFormField({
  initialValue,
  onChange,
  render,
  label,
  disabled = false,
  className = '',
}: CheckboxFormFieldProps) {
  const [value, setValue] = React.useState(initialValue);

  const handleChange = (checked: boolean) => {
    if (disabled) return;
    setValue(checked);
    onChange(checked);
  };

  React.useEffect(() => {
    setValue(initialValue);
  }, [initialValue]);

  // If render prop is provided, use it (for custom rendering)
  if (render) {
    return <>{render(value, handleChange)}</>;
  }

  // Default styled checkbox
  return (
    <div className={`checkbox-form-field ${className}`}>
      <input
        type="checkbox"
        className="checkbox-input"
        checked={value}
        onChange={(e) => handleChange(e.target.checked)}
        disabled={disabled}
        id={`checkbox-${Math.random().toString(36).substr(2, 9)}`}
      />
      {label && (
        <label
          className={`checkbox-label ${disabled ? 'disabled' : ''}`}
          onClick={() => handleChange(!value)}
        >
          {label}
        </label>
      )}
    </div>
  );
}

export default CheckboxFormField;
