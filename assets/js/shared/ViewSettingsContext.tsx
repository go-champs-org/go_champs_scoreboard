import React, { createContext, ReactNode, useContext, useMemo } from 'react';
import { BasketballViews } from '../types';

interface ViewSettingsContextType {
  selectedView: BasketballViews | 'default';
}

const ViewSettingsContext = createContext<ViewSettingsContextType>({
  selectedView: 'default',
});

interface ViewSettingsProviderProps {
  children: ReactNode;
  selectedView: BasketballViews | 'default';
}

export const ViewSettingsProvider: React.FC<ViewSettingsProviderProps> = ({
  children,
  selectedView,
}) => {
  const value = useMemo(
    () => ({
      selectedView,
    }),
    [selectedView],
  );

  return (
    <ViewSettingsContext.Provider value={value}>
      {children}
    </ViewSettingsContext.Provider>
  );
};

// Custom hook for consuming the view settings context
// Accepts an optional override parameter that takes precedence over context value
export const useSelectedView = (
  override?: BasketballViews,
): BasketballViews | 'default' => {
  const context = useContext(ViewSettingsContext);
  return override || context.selectedView;
};
