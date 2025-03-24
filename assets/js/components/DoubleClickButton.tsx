import React from 'react';

interface DoubleClickButtonProps {
  onClick: () => void;
  children?: React.ReactNode;
  className?: string;
  disabled?: boolean;
}

function DoubleClickButton({
  className,
  children,
  onClick,
  disabled = false,
}: DoubleClickButtonProps) {
  const [clickCount, setClickCount] = React.useState(0);

  const handleClick = () => {
    setClickCount(clickCount + 1);
    if (clickCount === 1) {
      onClick();
      setClickCount(0);
    }
  };

  return (
    <button
      className={`${className} ${clickCount === 1 ? 'is-danger' : ''}`}
      onClick={handleClick}
      disabled={disabled}
    >
      {children}
    </button>
  );
}

export default DoubleClickButton;
