import React, { createContext, ReactNode, useContext, useMemo } from 'react';
import { BasketballViews, RulesVersion } from '../types';

interface ViewSettingsContextType {
  selectedView: BasketballViews | 'default';
  rulesVersion: RulesVersion;
}

const ViewSettingsContext = createContext<ViewSettingsContextType>({
  selectedView: 'default',
  rulesVersion: 'fiba-2024',
});

interface ViewSettingsProviderProps {
  children: ReactNode;
  selectedView: BasketballViews | 'default';
  rulesVersion?: RulesVersion;
}

export const ViewSettingsProvider: React.FC<ViewSettingsProviderProps> = ({
  children,
  selectedView,
  rulesVersion = 'fiba-2024',
}) => {
  const value = useMemo(
    () => ({
      selectedView,
      rulesVersion,
    }),
    [selectedView, rulesVersion],
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

// Custom hook for consuming the FIBA rules version of the game
export const useRulesVersion = (): RulesVersion => {
  const context = useContext(ViewSettingsContext);
  return context.rulesVersion;
};
