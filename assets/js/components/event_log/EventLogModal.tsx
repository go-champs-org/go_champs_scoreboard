import React, { useEffect, useState } from 'react';

import Modal from '../Modal';
import {
  GameState,
  EventLog,
  PostEventLog,
  PutEventLog,
  BasketballViews,
} from '../../types';
import eventLogsHttpClient from '../../features/event_logs/eventLogsHttpClient';
import EventLogTable from './EventLogTable';
import EventLogForm from './EventLogForm';
import { useTranslation } from 'react-i18next';
import { EVENT_KEYS } from '../../constants';
import { getManualPlayerStatsForView } from '../basketball_5x5/constants';

interface EventLogModalProps {
  game_state: GameState;
  showModal: boolean;
  onCloseModal: () => void;
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
    <div
      className="has-text-centered"
      style={{ height: '100px', width: '100%' }}
    >
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

interface StatFilterProps {
  selectedStat: string | null;
  onStatFilter: (statKey: string | null) => void;
  showForm: boolean;
  currentView: BasketballViews;
}

function StatFilter({
  selectedStat,
  onStatFilter,
  showForm,
  currentView,
}: StatFilterProps) {
  const { t } = useTranslation();

  if (showForm) return null;

  const availableStats = getManualPlayerStatsForView(currentView);

  return (
    <div className="field">
      <label className="label has-text-white-ter">
        {t('basketball.modals.eventLogs.statFilter')}
      </label>
      <div className="control">
        <div className="select is-fullwidth">
          <select
            value={selectedStat || ''}
            onChange={(e) => onStatFilter(e.target.value || null)}
          >
            <option value="">
              {t('basketball.modals.eventLogs.allStats')}
            </option>
            {availableStats.map((stat) => (
              <option key={stat.key} value={stat.key}>
                {t(stat.labelTranslationKey)}
              </option>
            ))}
          </select>
        </div>
      </div>
    </div>
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
  const [selectedStat, setSelectedStat] = useState<string | null>(null);
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
    let filtered = eventLogs;

    // Filter by quarter
    if (selectedQuarter !== null) {
      filtered = filtered.filter(
        (log) => log.game_clock_period === selectedQuarter,
      );
    }

    // Filter by stat (only for UPDATE_PLAYER_STAT events)
    if (selectedStat !== null) {
      filtered = filtered.filter(
        (log) =>
          log.key === EVENT_KEYS.UPDATE_PLAYER_STAT &&
          log.payload?.['stat-id'] === selectedStat,
      );
    }

    setFilteredEventLogs(filtered);
  }, [eventLogs, selectedQuarter, selectedStat]);

  const handleQuarterFilter = async (quarter: number | null) => {
    setSelectedQuarter(quarter);
    // Fetch new data when quarter filter changes
    await fetchEventLogs(quarter);
  };

  const handleStatFilter = (statKey: string | null) => {
    setSelectedStat(statKey);
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
    selectedStat,
    availableQuarters,
    handleQuarterFilter,
    handleStatFilter,
    handleDeleteEvent,
  };
}

function EventLogModal({
  game_state,
  showModal,
  onCloseModal,
}: EventLogModalProps) {
  const { t } = useTranslation();
  const gameId = game_state.id;
  const [showForm, setShowForm] = useState(false);
  const [isPosting, setIsPosting] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [editingEvent, setEditingEvent] = useState<EventLog | null>(null);
  const currentPeriod = game_state.clock_state.period;

  const {
    filteredEventLogs,
    loading,
    selectedQuarter,
    selectedStat,
    availableQuarters,
    handleQuarterFilter,
    handleStatFilter,
    handleDeleteEvent,
  } = useEventLogs(gameId, showModal, currentPeriod);

  const handleToggleForm = () => {
    setShowForm(!showForm);
    setEditingEvent(null); // Clear editing when toggling
    setSubmitError(null);
  };

  const handleEditEvent = (eventLog: EventLog) => {
    setEditingEvent(eventLog);
    setShowForm(true);
    setSubmitError(null);
  };

  const handleFormSubmit = async (eventData: PostEventLog) => {
    try {
      setIsPosting(true);
      setSubmitError(null);

      if (editingEvent) {
        await eventLogsHttpClient.putEventLog(
          editingEvent.id,
          eventData.payload!,
        );
        await handleQuarterFilter(editingEvent.game_clock_period);
      } else {
        // Create new event
        await eventLogsHttpClient.postEventLogs(eventData);
        await handleQuarterFilter(eventData.game_clock_period);
      }

      setShowForm(false);
      setEditingEvent(null);
    } catch (error) {
      console.error('Error creating/updating event:', error);
      const errorMessage =
        error instanceof Error
          ? error.message
          : `An unexpected error occurred while ${
              editingEvent ? 'updating' : 'creating'
            } the event. Please try again.`;
      setSubmitError(errorMessage);
    } finally {
      setIsPosting(false);
    }
  };

  const handleFormCancel = () => {
    setShowForm(false);
    setEditingEvent(null); // Clear editing when cancelling
    setSubmitError(null);
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
              <div className="columns is-multiline">
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
                <div className="column is-12">
                  <StatFilter
                    selectedStat={selectedStat}
                    onStatFilter={handleStatFilter}
                    showForm={showForm}
                    currentView={game_state.view_settings_state.view}
                  />
                </div>
              </div>
            </div>
            <div className="column is-12">
              {showForm ? (
                <EventLogForm
                  gameState={game_state}
                  isSubmitting={isPosting}
                  submitError={submitError}
                  editingEvent={editingEvent}
                  onSubmit={handleFormSubmit}
                  onCancel={handleFormCancel}
                />
              ) : (
                <EventLogTable
                  eventLogs={filteredEventLogs}
                  selectedQuarter={selectedQuarter}
                  gameState={game_state}
                  onDeleteEvent={handleDeleteEvent}
                  onEditEvent={handleEditEvent}
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
