import React from 'react';

interface PopUpButtonOption {
  label: string;
  onClick: () => void;
  className?: string;
  disabled?: boolean;
}

interface PopUpButtonProps {
  popUpPanel?: React.ReactNode;
  popUpButtons?: PopUpButtonOption[];
  popUpDirection?: 'top' | 'bottom' | 'left' | 'right';
  onQuickClick: () => void;
  children: React.ReactNode;
  disabled?: boolean;
  className?: string;
  holdDuration?: number; // in milliseconds, default 1000ms (1 seconds)
  keyboardKey?: string;
}

function PopUpButton(props: PopUpButtonProps) {
  const {
    popUpPanel,
    popUpButtons = [],
    popUpDirection = 'top',
    onQuickClick,
    children,
    className,
    holdDuration = 1000,
    disabled = false,
    keyboardKey,
  } = props;

  const [isOpen, setIsOpen] = React.useState(false);
  const [isHolding, setIsHolding] = React.useState(false);
  const popupRef = React.useRef<HTMLDivElement>(null);
  const firstButtonRef = React.useRef<HTMLButtonElement>(null);
  const holdTimeoutRef = React.useRef<NodeJS.Timeout | null>(null);
  const holdCompletedRef = React.useRef<boolean>(false);
  const isHoldingRef = React.useRef<boolean>(false);

  // Shared logic for starting hold action
  const startHold = () => {
    if (disabled || isHoldingRef.current) return;

    setIsHolding(true);
    isHoldingRef.current = true;
    holdCompletedRef.current = false;

    // Start the hold timer
    holdTimeoutRef.current = setTimeout(() => {
      holdCompletedRef.current = true;
      setIsOpen(true);
      setIsHolding(false);
      isHoldingRef.current = false;

      // Focus the first button in the popup when it opens
      setTimeout(() => {
        if (firstButtonRef.current) {
          firstButtonRef.current.focus();
        }
      }, 100); // Small delay to ensure popup is rendered
    }, holdDuration);
  };

  // Shared logic for stopping hold action
  const stopHold = () => {
    if (disabled) return;

    if (holdTimeoutRef.current) {
      clearTimeout(holdTimeoutRef.current);
      holdTimeoutRef.current = null;
    }

    if (isHoldingRef.current && !holdCompletedRef.current) {
      onQuickClick();
    }

    setIsHolding(false);
    isHoldingRef.current = false;
    holdCompletedRef.current = false;
  };

  const onMouseDown = () => {
    startHold();
  };

  const onMouseUp = () => {
    stopHold();
  };

  const onMouseLeave = () => {
    // Treat mouse leave as mouse up
    stopHold();
  };

  React.useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        popupRef.current &&
        !popupRef.current.contains(event.target as Node)
      ) {
        setIsOpen(false);
      }
    };

    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isOpen]);

  // Handle popup keyboard navigation
  React.useEffect(() => {
    if (!isOpen) return;

    const handlePopupKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        setIsOpen(false);
      }
    };

    document.addEventListener('keydown', handlePopupKeyDown);
    return () => {
      document.removeEventListener('keydown', handlePopupKeyDown);
    };
  }, [isOpen]);

  // Keyboard event listeners
  React.useEffect(() => {
    if (!keyboardKey) return;

    const handleKeyDown = (event: KeyboardEvent) => {
      const isModalOpen = document.querySelector('.modal.is-active') !== null;
      if (isModalOpen) return;

      if (event.key === keyboardKey && !event.repeat) {
        event.preventDefault();
        startHold();
      }
    };

    const handleKeyUp = (event: KeyboardEvent) => {
      const isModalOpen = document.querySelector('.modal.is-active') !== null;
      if (isModalOpen) return;

      if (event.key === keyboardKey) {
        event.preventDefault();
        stopHold();
      }
    };

    document.addEventListener('keydown', handleKeyDown);
    document.addEventListener('keyup', handleKeyUp);

    return () => {
      document.removeEventListener('keydown', handleKeyDown);
      document.removeEventListener('keyup', handleKeyUp);
    };
  }, [keyboardKey, disabled, holdDuration]);

  // Cleanup on unmount
  React.useEffect(() => {
    return () => {
      if (holdTimeoutRef.current) {
        clearTimeout(holdTimeoutRef.current);
      }
    };
  }, []);

  const getPopupClasses = () => {
    const baseClasses = 'pop-up-panel';
    const directionClass = `pop-up-panel--${popUpDirection}`;
    const openClass = isOpen ? 'pop-up-panel--open' : '';
    return `${baseClasses} ${directionClass} ${openClass}`.trim();
  };

  const getButtonClasses = () => {
    const baseClasses = 'pop-up-button';
    const customClass = className || '';
    const holdingClass = isHolding ? 'pop-up-button--holding' : '';
    const directionClass = `pop-up-button--${popUpDirection}`;
    return `${baseClasses} ${customClass} ${holdingClass} ${directionClass}`.trim();
  };

  const renderPopupContent = () => {
    if (popUpPanel) {
      return popUpPanel;
    }

    if (popUpButtons.length > 0) {
      return (
        <div className="columns is-multiline is-1">
          {popUpButtons.map((button, index) => (
            <div key={index} className="column is-narrow is-12">
              <button
                ref={index === 0 ? firstButtonRef : undefined}
                className={`button is-fullwidth is-small ${
                  button.className || ''
                }`}
                onClick={() => {
                  button.onClick();
                  setIsOpen(false);
                }}
                disabled={button.disabled}
              >
                {button.label}
              </button>
            </div>
          ))}
        </div>
      );
    }

    return null;
  };

  return (
    <div className="pop-up-container" ref={popupRef}>
      <button
        className={getButtonClasses()}
        onMouseDown={onMouseDown}
        onMouseUp={onMouseUp}
        onMouseLeave={onMouseLeave}
        disabled={disabled}
        style={
          {
            '--hold-duration': `${holdDuration}ms`,
          } as React.CSSProperties & { [key: string]: any }
        }
      >
        {children}
      </button>
      <div className={getPopupClasses()}>{renderPopupContent()}</div>
    </div>
  );
}

export default PopUpButton;
