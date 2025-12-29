import React, { createContext, ReactNode, useContext, useMemo } from 'react';

interface ConfigType {
  go_champs_api_token: string;
  go_champs_api: string;
}

class Config {
  configPayload: ConfigType;

  constructor(config: string) {
    this.configPayload = JSON.parse(config);
  }

  getApiToken(): string {
    return this.configPayload.go_champs_api_token;
  }

  getApiHost(): string {
    return this.configPayload.go_champs_api;
  }
}

interface ConfigContextType {
  config: Config;
}

const defaultConfig = new Config('{}');
const ConfigContext = createContext<Config>(defaultConfig);

export function ConfigProvider({
  children,
  configString = '{}',
}: {
  children: ReactNode;
  configString?: string;
}) {
  const config = useMemo(
    () => new Config(configString || '{}'),
    [configString],
  );

  return (
    <ConfigContext.Provider value={config}>{children}</ConfigContext.Provider>
  );
}

// Custom hook for consuming the config context
export const useConfig = () => useContext(ConfigContext);
