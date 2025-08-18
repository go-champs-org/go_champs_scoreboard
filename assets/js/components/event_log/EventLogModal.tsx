import React, { useEffect, useState } from 'react';

import Modal from '../Modal';
import { GameState, EventLog, PostEventLog } from '../../types';
import eventLogsHttpClient from '../../features/event_logs/eventLogsHttpClient';
import EventLogTable from './EventLogTable';
import EventLogForm from './EventLogForm';
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
  showForm: boolean;
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
  showForm,
}: QuarterFilterProps) {
  const { t } = useTranslation();

  if (availableQuarters.length === 0 && !showForm) return <></>;

  return (
    <div className="field is-grouped mb-4">
      {!showForm && (
        <>
          {availableQuarters.map((quarter) => (
            <div key={quarter} className="control">
              <button
                className={`button is-small ${
                  selectedQuarter === quarter ? 'is-primary' : 'is-light'
                }`}
                onClick={() => onQuarterFilter(quarter)}
              >
                Q{quarter}
              </button>
            </div>
          ))}
        </>
      )}
    </div>
  );
}

interface ToggleViewButtonProps {
  showForm: boolean;
  onToggleForm: () => void;
}

function ToggleViewButton({ showForm, onToggleForm }: ToggleViewButtonProps) {
  const { t } = useTranslation();

  return (
    <button className="button is-info is-small" onClick={onToggleForm}>
      {showForm
        ? t('basketball.modals.eventLogs.showEvents')
        : t('basketball.modals.eventLogs.addEvent')}
    </button>
  );
}

function useEventLogs(
  gameId: string,
  showModal: boolean,
  currentPeriod: number,
) {
  const [eventLogs, setEventLogs] = useState<EventLog[]>([]);
  const [filteredEventLogs, setFilteredEventLogs] = useState<EventLog[]>([]);
  const [loading, setLoading] = useState(false);
  const [selectedQuarter, setSelectedQuarter] = useState<number | null>(
    currentPeriod,
  );
  const [availableQuarters, setAvailableQuarters] = useState<number[]>([]);

  const fetchEventLogs = async (period?: number | null) => {
    setLoading(true);
    try {
      const filters = period
        ? { game_clock_period: period.toString() }
        : undefined;
      const response = await eventLogsHttpClient.getEventLogs(gameId, filters);
      setEventLogs(response);

      if (response.length > 0) {
        const maxQuarter = Math.max(
          ...response.map((log) => log.game_clock_period),
        );
        const totalQuarters = Math.max(maxQuarter, currentPeriod);
        const quarters = Array.from({ length: totalQuarters }, (_, i) => i + 1);
        setAvailableQuarters(quarters);
      } else {
        const quarters = Array.from({ length: currentPeriod }, (_, i) => i + 1);
        setAvailableQuarters(quarters);
      }
    } catch (error) {
      console.error('Error fetching event logs:', error);
      setEventLogs([]);
      const quarters = Array.from({ length: currentPeriod }, (_, i) => i + 1);
      setAvailableQuarters(quarters);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (showModal) {
      // Initialize with current period
      setSelectedQuarter(currentPeriod);
      fetchEventLogs(currentPeriod);
    }
  }, [showModal, gameId, currentPeriod]);

  useEffect(() => {
    if (selectedQuarter === null) {
      setFilteredEventLogs(eventLogs);
    } else {
      setFilteredEventLogs(
        eventLogs.filter((log) => log.game_clock_period === selectedQuarter),
      );
    }
  }, [eventLogs, selectedQuarter]);

  const handleQuarterFilter = async (quarter: number | null) => {
    setSelectedQuarter(quarter);
    // Fetch new data when quarter filter changes
    await fetchEventLogs(quarter);
  };

  const handleDeleteEvent = async (eventId: string) => {
    try {
      await eventLogsHttpClient.deleteEvent(eventId);
      setEventLogs((prevLogs) => prevLogs.filter((log) => log.id !== eventId));
    } catch (error) {
      console.error('Error deleting event log:', error);
    }
  };

  return {
    filteredEventLogs,
    loading,
    selectedQuarter,
    availableQuarters,
    handleQuarterFilter,
    handleDeleteEvent,
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
  const [showForm, setShowForm] = useState(false);
  const [isPosting, setIsPosting] = useState(false);
  const currentPeriod = game_state.clock_state.period;

  const {
    filteredEventLogs,
    loading,
    selectedQuarter,
    availableQuarters,
    handleQuarterFilter,
    handleDeleteEvent,
  } = useEventLogs(gameId, showModal, currentPeriod);

  const handleToggleForm = () => {
    setShowForm(!showForm);
  };

  const handleFormSubmit = async (eventData: PostEventLog) => {
    try {
      setIsPosting(true);
      await eventLogsHttpClient.postEventLogs(eventData);
      await handleQuarterFilter(eventData.game_clock_period);

      setShowForm(false);
    } catch (error) {
      console.error('Error creating event:', error);
    } finally {
      setIsPosting(false);
    }
  };

  const handleFormCancel = () => {
    setShowForm(false);
  };

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
          <div className="columns is-multiline">
            <div className="column is-12">
              <div className="columns">
                <div className="column is-6">
                  <QuarterFilter
                    availableQuarters={availableQuarters}
                    selectedQuarter={selectedQuarter}
                    onQuarterFilter={handleQuarterFilter}
                    showForm={showForm}
                  />
                </div>
                <div className="column is-6 has-text-right">
                  <ToggleViewButton
                    showForm={showForm}
                    onToggleForm={handleToggleForm}
                  />
                </div>
              </div>
            </div>
            <div className="column is-12">
              {showForm ? (
                <EventLogForm
                  gameState={game_state}
                  isSubmitting={isPosting}
                  onSubmit={handleFormSubmit}
                  onCancel={handleFormCancel}
                />
              ) : (
                <EventLogTable
                  eventLogs={filteredEventLogs}
                  selectedQuarter={selectedQuarter}
                  gameState={game_state}
                  onDeleteEvent={handleDeleteEvent}
                />
              )}
            </div>
          </div>
        )}
      </div>
    </Modal>
  );
}

export default EventLogModal;
