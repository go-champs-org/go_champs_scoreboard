import React, { useEffect, useState } from 'react';

import Modal from '../Modal';
import { GameState, EventLog } from '../../types';
import eventLogsHttpClient from '../../features/event_logs/eventLogsHttpClient';
import { formatTime } from '../../shared/contentHelpers';
import { payloadToString } from './payloadMapper';
import { useTranslation } from 'react-i18next';

interface EventLogModalProps {
  game_state: GameState;
  showModal: boolean;
  onCloseModal: () => void;
  pushEvent: (event: string, data: any) => void;
}

interface QuarterFilterProps {
  availableQuarters: number[];
  selectedQuarter: number | null;
  onQuarterFilter: (quarter: number | null) => void;
}

interface EventLogTableProps {
  eventLogs: EventLog[];
  selectedQuarter: number | null;
  gameState: GameState;
}

interface LoadingStateProps {}

const LoadingState: React.FC<LoadingStateProps> = () => {
  const { t } = useTranslation();
  return (
    <div className="has-text-centered">
      <div className="is-loading">
        {t('basketball.modals.eventLogs.loading')}
      </div>
    </div>
  );
};

const QuarterFilter: React.FC<QuarterFilterProps> = ({
  availableQuarters,
  selectedQuarter,
  onQuarterFilter,
}) => {
  const { t } = useTranslation();

  if (availableQuarters.length === 0) return null;

  return (
    <div className="field is-grouped mb-4">
      <div className="control">
        <button
          className={`button ${
            selectedQuarter === null ? 'is-primary' : 'is-light'
          }`}
          onClick={() => onQuarterFilter(null)}
        >
          {t('basketball.modals.eventLogs.allQuarters')}
        </button>
      </div>
      {availableQuarters.map((quarter) => (
        <div key={quarter} className="control">
          <button
            className={`button ${
              selectedQuarter === quarter ? 'is-primary' : 'is-light'
            }`}
            onClick={() => onQuarterFilter(quarter)}
          >
            Q{quarter}
          </button>
        </div>
      ))}
    </div>
  );
};

const EventLogTable: React.FC<EventLogTableProps> = ({
  eventLogs,
  selectedQuarter,
  gameState,
}) => {
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
            <tr key={eventLog.id}>
              <td>{eventLog.game_clock_period}</td>
              <td>{formatTime(eventLog.game_clock_time)}</td>
              <td>{eventLog.key}</td>
              <td>
                {eventLog.payload
                  ? payloadToString(eventLog.payload, gameState, t)
                  : ''}
              </td>
            </tr>
          ))
        )}
      </tbody>
    </table>
  );
};

// Hook for managing event logs data and filtering
const useEventLogs = (gameId: string, showModal: boolean) => {
  const [eventLogs, setEventLogs] = useState<EventLog[]>([]);
  const [filteredEventLogs, setFilteredEventLogs] = useState<EventLog[]>([]);
  const [loading, setLoading] = useState(false);
  const [selectedQuarter, setSelectedQuarter] = useState<number | null>(null);
  const [availableQuarters, setAvailableQuarters] = useState<number[]>([]);

  // Fetch event logs when modal opens
  useEffect(() => {
    if (showModal) {
      const fetchEventLogs = async () => {
        setLoading(true);
        try {
          const response = await eventLogsHttpClient.getEventLogs(gameId);
          setEventLogs(response);

          // Calculate available quarters based on max game_clock_period
          if (response.length > 0) {
            const maxQuarter = Math.max(
              ...response.map((log) => log.game_clock_period),
            );
            const quarters = Array.from(
              { length: maxQuarter },
              (_, i) => i + 1,
            );
            setAvailableQuarters(quarters);
          } else {
            setAvailableQuarters([]);
          }

          // Reset filter when new data is loaded
          setSelectedQuarter(null);
        } catch (error) {
          console.error('Error fetching event logs:', error);
          setEventLogs([]);
          setAvailableQuarters([]);
        } finally {
          setLoading(false);
        }
      };

      fetchEventLogs();
    }
  }, [showModal, gameId]);

  // Filter event logs based on selected quarter
  useEffect(() => {
    if (selectedQuarter === null) {
      setFilteredEventLogs(eventLogs);
    } else {
      setFilteredEventLogs(
        eventLogs.filter((log) => log.game_clock_period === selectedQuarter),
      );
    }
  }, [eventLogs, selectedQuarter]);

  const handleQuarterFilter = (quarter: number | null) => {
    setSelectedQuarter(quarter);
  };

  return {
    filteredEventLogs,
    loading,
    selectedQuarter,
    availableQuarters,
    handleQuarterFilter,
  };
};

function EventLogModal({
  game_state,
  showModal,
  onCloseModal,
  pushEvent,
}: EventLogModalProps) {
  const { t } = useTranslation();
  const gameId = game_state.id;

  const {
    filteredEventLogs,
    loading,
    selectedQuarter,
    availableQuarters,
    handleQuarterFilter,
  } = useEventLogs(gameId, showModal);

  return (
    <Modal
      title={t('basketball.modals.eventLogs.title')}
      showModal={showModal}
      onClose={onCloseModal}
      modalCardStyle={{ width: '1024px' }}
    >
      <div className="modal-card-body">
        {loading ? (
          <LoadingState />
        ) : (
          <>
            <QuarterFilter
              availableQuarters={availableQuarters}
              selectedQuarter={selectedQuarter}
              onQuarterFilter={handleQuarterFilter}
            />
            <EventLogTable
              eventLogs={filteredEventLogs}
              selectedQuarter={selectedQuarter}
              gameState={game_state}
            />
          </>
        )}
      </div>
    </Modal>
  );
}

export default EventLogModal;
