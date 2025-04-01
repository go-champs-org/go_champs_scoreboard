import React from 'react';
import { LiveSocket } from 'phoenix_live_view';

declare global {
  interface Window {
    liveSocket?: LiveSocket;
  }
}

function useConnectionState() {
  const [currentConnectionState, setCurrentConnectionState] = React.useState<
    'connected' | 'disconnected'
  >('connected');

  const handleOnline = () => setCurrentConnectionState('connected');
  const handleOffline = () => setCurrentConnectionState('disconnected');

  React.useEffect(() => {
    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  return currentConnectionState;
}

export default useConnectionState;
