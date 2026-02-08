import React, { useState, useRef, useEffect } from 'react';

interface AutocompleteInputProps<T> {
  value: string;
  onChange: (value: string) => void;
  onSelect: (item: T | null) => void;
  items: T[];
  getItemText: (item: T) => string;
  getItemKey: (item: T) => string;
  getItemSubtitle?: (item: T) => string | null;
  placeholder?: string;
  className?: string;
  autoFocus?: boolean;
}

function AutocompleteInput<T>({
  value,
  onChange,
  onSelect,
  items,
  getItemText,
  getItemKey,
  getItemSubtitle,
  placeholder,
  className = 'input is-small',
  autoFocus = false,
}: AutocompleteInputProps<T>) {
  const [showDropdown, setShowDropdown] = useState(false);
  const [selectedIndex, setSelectedIndex] = useState(-1);
  const [dropdownDirection, setDropdownDirection] = useState<'down' | 'up'>(
    'down',
  );
  const inputRef = useRef<HTMLInputElement>(null);
  const dropdownRef = useRef<HTMLDivElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  // Filter items based on input value (case-insensitive partial matching)
  const filteredItems = items.filter((item) =>
    getItemText(item).toLowerCase().includes(value.toLowerCase()),
  );

  // Check if current value matches any item exactly
  const isExistingItem = items.some(
    (item) => getItemText(item).toLowerCase() === value.toLowerCase(),
  );

  // Calculate dropdown direction and position based on available space
  useEffect(() => {
    if (showDropdown && inputRef.current && dropdownRef.current) {
      const inputRect = inputRef.current.getBoundingClientRect();
      const viewportHeight = window.innerHeight;
      const spaceBelow = viewportHeight - inputRect.bottom;
      const spaceAbove = inputRect.top;
      const dropdownHeight = 200; // max-height from CSS

      const dropdown = dropdownRef.current;

      // Show dropdown above if not enough space below and more space above
      if (spaceBelow < dropdownHeight && spaceAbove > spaceBelow) {
        setDropdownDirection('up');
        dropdown.style.bottom = `${viewportHeight - inputRect.top + 2}px`;
        dropdown.style.top = 'auto';
      } else {
        setDropdownDirection('down');
        dropdown.style.top = `${inputRect.bottom + 2}px`;
        dropdown.style.bottom = 'auto';
      }

      dropdown.style.left = `${inputRect.left}px`;
    }
  }, [showDropdown, filteredItems.length]);

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        dropdownRef.current &&
        !dropdownRef.current.contains(event.target as Node) &&
        inputRef.current &&
        !inputRef.current.contains(event.target as Node)
      ) {
        setShowDropdown(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = e.target.value;
    onChange(newValue);
    setShowDropdown(true);
    setSelectedIndex(-1);
    onSelect(null); // Reset selection when typing
  };

  const handleItemSelect = (item: T) => {
    onChange(getItemText(item));
    onSelect(item);
    setShowDropdown(false);
    setSelectedIndex(-1);
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (!showDropdown) {
      if (e.key === 'ArrowDown' && filteredItems.length > 0) {
        e.preventDefault();
        setShowDropdown(true);
        setSelectedIndex(0);
      }
      return;
    }

    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault();
        setSelectedIndex((prev) =>
          prev < filteredItems.length - 1 ? prev + 1 : prev,
        );
        break;
      case 'ArrowUp':
        e.preventDefault();
        setSelectedIndex((prev) => (prev > 0 ? prev - 1 : -1));
        break;
      case 'Enter':
        e.preventDefault();
        if (selectedIndex >= 0 && selectedIndex < filteredItems.length) {
          handleItemSelect(filteredItems[selectedIndex]);
        } else {
          setShowDropdown(false);
        }
        break;
      case 'Escape':
        e.preventDefault();
        setShowDropdown(false);
        setSelectedIndex(-1);
        break;
    }
  };

  const handleFocus = () => {
    if (value && filteredItems.length > 0) {
      setShowDropdown(true);
    }
  };

  return (
    <div className="autocomplete-input" ref={containerRef}>
      <div className="control">
        <input
          ref={inputRef}
          className={className}
          type="text"
          value={value}
          onChange={handleInputChange}
          onKeyDown={handleKeyDown}
          onFocus={handleFocus}
          placeholder={placeholder}
          autoFocus={autoFocus}
        />
        {value && !isExistingItem && (
          <span
            className="new-entry-indicator"
            title="New entry - not in database"
          >
            *
          </span>
        )}
      </div>

      {showDropdown && filteredItems.length > 0 && (
        <div
          ref={dropdownRef}
          className={`dropdown-menu dropdown-${dropdownDirection}`}
        >
          <div className="dropdown-content">
            {filteredItems.map((item, index) => {
              const subtitle = getItemSubtitle?.(item);
              return (
                <a
                  key={getItemKey(item)}
                  className={`dropdown-item ${
                    index === selectedIndex ? 'is-active' : ''
                  }`}
                  onClick={() => handleItemSelect(item)}
                  onMouseEnter={() => setSelectedIndex(index)}
                >
                  <div>
                    <strong>{getItemText(item)}</strong>
                    {subtitle && (
                      <span className="item-subtitle">({subtitle})</span>
                    )}
                  </div>
                </a>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
}

export default AutocompleteInput;
