import React from 'react';

interface PopUpButtonOption {
  label: string;
  onClick: () => void;
  className?: string;
  disabled?: boolean;
}

interface PopUpButtonPanelRef {
  close: () => void;
  firstButtonRef: React.RefObject<HTMLButtonElement | null>;
}

interface PopUpButtonProps {
  popUpPanel?:
    | React.ReactNode
    | ((panelRef: PopUpButtonPanelRef) => React.ReactNode);
  popUpButtons?: PopUpButtonOption[];
  popUpDirection?: 'top' | 'bottom' | 'left' | 'right';
  children: React.ReactNode;
  disabled?: boolean;
  className?: string;
  keyboardKey?: string;
}

function PopUpButton(props: PopUpButtonProps) {
  const {
    popUpPanel,
    popUpButtons = [],
    popUpDirection = 'top',
    children,
    className,
    disabled = false,
    keyboardKey,
  } = props;

  const [isOpen, setIsOpen] = React.useState(false);
  const popupRef = React.useRef<HTMLDivElement>(null);
  const firstButtonRef = React.useRef<HTMLButtonElement>(null);

  const handleClick = () => {
    if (disabled) return;

    setIsOpen(true);

    // Focus the first button in the popup when it opens
    setTimeout(() => {
      if (firstButtonRef.current) {
        firstButtonRef.current.focus();
      }
    }, 100); // Small delay to ensure popup is rendered
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
        handleClick();
      }
    };

    document.addEventListener('keydown', handleKeyDown);

    return () => {
      document.removeEventListener('keydown', handleKeyDown);
    };
  }, [keyboardKey, disabled]);

  const getPopupClasses = () => {
    const baseClasses = 'pop-up-panel';
    const directionClass = `pop-up-panel--${popUpDirection}`;
    const openClass = isOpen ? 'pop-up-panel--open' : '';
    return `${baseClasses} ${directionClass} ${openClass}`.trim();
  };

  const getButtonClasses = () => {
    const baseClasses = 'pop-up-button';
    const customClass = className || '';
    const directionClass = `pop-up-button--${popUpDirection}`;
    return `${baseClasses} ${customClass} ${directionClass}`.trim();
  };

  const renderPopupContent = () => {
    if (popUpPanel) {
      if (typeof popUpPanel === 'function') {
        const panelRef: PopUpButtonPanelRef = {
          close: () => setIsOpen(false),
          firstButtonRef,
        };
        return popUpPanel(panelRef);
      }
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
        onClick={handleClick}
        disabled={disabled}
      >
        {children}
      </button>
      <div className={getPopupClasses()}>{renderPopupContent()}</div>
    </div>
  );
}

export default PopUpButton;
