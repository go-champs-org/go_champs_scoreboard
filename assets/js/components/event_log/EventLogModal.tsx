import React, { useEffect, useState } from 'react';

import Modal from '../Modal';
import { GameState, EventLog } from '../../types';
import eventLogsHttpClient from '../../features/event_logs/eventLogsHttpClient';
import EventLogTable from './EventLogTable';
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

function LoadingState() {
  const { t } = useTranslation();
  return (
    <div className="has-text-centered">
      <div className="is-loading">
        {t('basketball.modals.eventLogs.loading')}
      </div>
    </div>
  );
}

function QuarterFilter({
  availableQuarters,
  selectedQuarter,
  onQuarterFilter,
}: QuarterFilterProps) {
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
}

function useEventLogs(gameId: string, showModal: boolean) {
  const [eventLogs, setEventLogs] = useState<EventLog[]>([]);
  const [filteredEventLogs, setFilteredEventLogs] = useState<EventLog[]>([]);
  const [loading, setLoading] = useState(false);
  const [selectedQuarter, setSelectedQuarter] = useState<number | null>(null);
  const [availableQuarters, setAvailableQuarters] = useState<number[]>([]);

  useEffect(() => {
    if (showModal) {
      const fetchEventLogs = async () => {
        setLoading(true);
        try {
          const response = await eventLogsHttpClient.getEventLogs(gameId);
          setEventLogs(response);

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
}

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
