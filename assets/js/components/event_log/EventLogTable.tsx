import React from 'react';
import { useTranslation } from 'react-i18next';
import { EventLog, GameState } from '../../types';
import { formatTime } from '../../shared/contentHelpers';
import { eventKeyToString } from './contentMappers';
import EventLogPayload from './EventLogPayload';

interface EventLogRowProps {
  eventLog: EventLog;
  gameState: GameState;
}

interface EventLogTableProps {
  eventLogs: EventLog[];
  selectedQuarter: number | null;
  gameState: GameState;
}

function EventLogRow({ eventLog, gameState }: EventLogRowProps) {
  const { t } = useTranslation();

  return (
    <tr key={eventLog.id}>
      <td>{eventLog.game_clock_period}</td>
      <td>{formatTime(eventLog.game_clock_time)}</td>
      <td>{eventKeyToString(eventLog.key, t)}</td>
      <td>
        <EventLogPayload eventLog={eventLog} gameState={gameState} />
      </td>
    </tr>
  );
}

function EventLogTable({
  eventLogs,
  selectedQuarter,
  gameState,
}: EventLogTableProps) {
  const { t } = useTranslation();

  const getEmptyStateMessage = () => {
    if (selectedQuarter === null) {
      return t('basketball.modals.eventLogs.noLogsFound');
    }
    return `${t(
      'basketball.modals.eventLogs.noLogsFoundForQuarter',
    )} Q${selectedQuarter}`;
  };

  return (
    <table className="table is-striped is-fullwidth">
      <thead>
        <tr>
          <th style={{ width: '50px' }}>
            {t('basketball.modals.eventLogs.table.quarter')}
          </th>
          <th style={{ width: '70px' }}>
            {t('basketball.modals.eventLogs.table.time')}
          </th>
          <th>{t('basketball.modals.eventLogs.table.event')}</th>
          <th>{t('basketball.modals.eventLogs.table.description')}</th>
        </tr>
      </thead>
      <tbody>
        {eventLogs.length === 0 ? (
          <tr>
            <td colSpan={4} className="has-text-centered">
              {getEmptyStateMessage()}
            </td>
          </tr>
        ) : (
          eventLogs.map((eventLog) => (
            <EventLogRow
              key={eventLog.id}
              eventLog={eventLog}
              gameState={gameState}
            />
          ))
        )}
      </tbody>
    </table>
  );
}

export default EventLogTable;
