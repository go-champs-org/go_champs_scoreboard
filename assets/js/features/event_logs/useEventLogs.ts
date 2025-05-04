import { useEffect, useState } from 'react';
import { EventLog } from '../../types';
import eventLogsHttpClient from './eventLogsHttpClient';

function useEventLogs(gameId: string) {
  const [eventLogs, setEventLogs] = useState<EventLog[]>([]);

  useEffect(() => {
    const fetchEventLogs = async () => {
      try {
        const response = await eventLogsHttpClient.getEventLogs(gameId);
        setEventLogs(response);
      } catch (error) {
        console.error('Error fetching event logs:', error);
      }
    };

    fetchEventLogs();
  }, [gameId]);

  return eventLogs;
}

export default useEventLogs;
