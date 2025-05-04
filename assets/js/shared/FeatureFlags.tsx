import React, {
  createContext,
  useContext,
  ReactNode,
  useMemo,
  useCallback,
} from 'react';

// Define the shape of our feature flags
export interface FeatureFlags {
  [key: string]: boolean;
}

// Create the context with default values
interface FeatureFlagContextType {
  flags: FeatureFlags;
  isEnabled: (flagName: string) => boolean;
}

const FeatureFlagContext = createContext<FeatureFlagContextType>({
  flags: {},
  isEnabled: () => false,
});

// Provider component
interface FeatureFlagProviderProps {
  children: ReactNode;
  initialFlags?: string; // JSON string of flags from server
}

export const FeatureFlagProvider: React.FC<FeatureFlagProviderProps> = ({
  children,
  initialFlags = '{}',
}) => {
  // Parse the flags from the JSON string
  const parsedFlags = useMemo(() => {
    try {
      return JSON.parse(initialFlags);
    } catch (e) {
      console.error('Error parsing feature flags:', e);
      return {};
    }
  }, [initialFlags]);

  // Helper function to check if a flag is enabled
  const isEnabled = useCallback(
    (flagName: string): boolean => {
      return Boolean(parsedFlags[flagName]);
    },
    [parsedFlags],
  );

  const value = useMemo(
    () => ({
      flags: parsedFlags,
      isEnabled,
    }),
    [parsedFlags, isEnabled],
  );

  return (
    <FeatureFlagContext.Provider value={value}>
      {children}
    </FeatureFlagContext.Provider>
  );
};

// Custom hook for consuming the feature flag context
export const useFeatureFlags = () => useContext(FeatureFlagContext);

// Component for conditionally rendering based on a feature flag
interface FeatureFlagProps {
  name: string;
  children: ReactNode;
  fallback?: ReactNode;
}

export const FeatureFlag: React.FC<FeatureFlagProps> = ({
  name,
  children,
  fallback = null,
}) => {
  const { isEnabled } = useFeatureFlags();
  return isEnabled(name) ? <>{children}</> : <>{fallback}</>;
};
