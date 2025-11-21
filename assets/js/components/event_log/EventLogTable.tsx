import React, { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { EventLog, GameState } from '../../types';
import { formatTime } from '../../shared/contentHelpers';
import { eventKeyToString } from './contentMappers';
import EventLogPayload from './EventLogPayload';
import DoubleClickButton from '../DoubleClickButton';

interface EventLogRowProps {
  eventLog: EventLog;
  gameState: GameState;
  onDeleteEvent: (eventId: string) => Promise<void>;
  onEditEvent: (eventLog: EventLog) => void;
  isDeleting: boolean;
  onStartDeleting: (eventId: string) => void;
}

interface EventLogTableProps {
  eventLogs: EventLog[];
  selectedQuarter: number | null;
  gameState: GameState;
  onDeleteEvent: (eventId: string) => Promise<void>;
  onEditEvent: (eventLog: EventLog) => void;
}

function EventLogRow({
  eventLog,
  gameState,
  onDeleteEvent,
  onEditEvent,
  isDeleting,
  onStartDeleting,
}: EventLogRowProps) {
  const { t } = useTranslation();
  const canDelete =
    eventLog.key === 'update-player-stat' ||
    eventLog.key === 'update-team-stat' ||
    eventLog.key === 'update-coach-stat';

  const canEdit =
    eventLog.key === 'update-player-stat' ||
    eventLog.key === 'update-coach-stat';

  const handleDelete = async () => {
    onStartDeleting(eventLog.id);
    // Add a small delay for the animation to show
    setTimeout(async () => {
      await onDeleteEvent(eventLog.id);
    }, 300);
  };

  const handleRowClick = () => {
    if (canEdit && !isDeleting) {
      onEditEvent(eventLog);
    }
  };

  return (
    <tr
      key={eventLog.id}
      className={`${isDeleting ? 'is-deleting' : ''} ${
        canEdit ? 'is-clickable' : ''
      }`}
      style={{
        transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
        transform: isDeleting
          ? 'translateX(-100%) scale(0.95)'
          : 'translateX(0) scale(1)',
        opacity: isDeleting ? 0 : 1,
        backgroundColor: isDeleting ? '#ffebee' : 'transparent',
        overflow: 'hidden',
        cursor: canEdit ? 'pointer' : 'default',
      }}
    >
      <td onClick={handleRowClick}>{eventLog.game_clock_period}</td>
      <td onClick={handleRowClick}>{formatTime(eventLog.game_clock_time)}</td>
      <td onClick={handleRowClick}>{eventKeyToString(eventLog.key, t)}</td>
      <td onClick={handleRowClick}>
        <EventLogPayload eventLog={eventLog} gameState={gameState} />
      </td>
      <td>
        <DoubleClickButton
          className={`button is-small is-fullwidth ${
            isDeleting ? 'is-loading is-danger' : 'is-warning'
          }`}
          disabled={!canDelete || isDeleting}
          onClick={handleDelete}
        >
          {!isDeleting && '✕'}
        </DoubleClickButton>
      </td>
    </tr>
  );
}

function EventLogTable({
  eventLogs,
  selectedQuarter,
  gameState,
  onDeleteEvent,
  onEditEvent,
}: EventLogTableProps) {
  const { t } = useTranslation();
  const [deletingEventIds, setDeletingEventIds] = useState<Set<string>>(
    new Set(),
  );

  const handleStartDeleting = (eventId: string) => {
    setDeletingEventIds((prev) => new Set(prev).add(eventId));
  };

  const handleDeleteEvent = async (eventId: string) => {
    await onDeleteEvent(eventId);
    // Remove from deleting state after successful deletion
    setDeletingEventIds((prev) => {
      const newSet = new Set(prev);
      newSet.delete(eventId);
      return newSet;
    });
  };

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
          <th>{t('basketball.modals.eventLogs.table.delete')}</th>
        </tr>
      </thead>
      <tbody>
        {eventLogs.length === 0 ? (
          <tr>
            <td colSpan={5} className="has-text-centered">
              {getEmptyStateMessage()}
            </td>
          </tr>
        ) : (
          eventLogs.map((eventLog) => (
            <EventLogRow
              key={eventLog.id}
              eventLog={eventLog}
              gameState={gameState}
              onDeleteEvent={handleDeleteEvent}
              onEditEvent={onEditEvent}
              isDeleting={deletingEventIds.has(eventLog.id)}
              onStartDeleting={handleStartDeleting}
            />
          ))
        )}
      </tbody>
    </table>
  );
}

export default EventLogTable;
