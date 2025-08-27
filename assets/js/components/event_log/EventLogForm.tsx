import React, { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { GameState, EventLog } from '../../types';
import { EVENT_KEYS_EDITABLE } from '../basketball_5x5/constants';
import PayloadForm from './PayloadForm';
import { eventKeyToString } from './contentMappers';
import { EVENT_KEYS } from '../../constants';

interface EventLogFormProps {
  gameState: GameState;
  isSubmitting?: boolean;
  submitError?: string | null;
  editingEvent?: EventLog | null;
  onSubmit: (eventData: any) => void;
  onCancel: () => void;
}

function EventLogForm({
  gameState,
  isSubmitting = false,
  submitError = null,
  editingEvent = null,
  onSubmit,
  onCancel,
}: EventLogFormProps) {
  const { t } = useTranslation();

  // Initialize form data based on editing mode
  const getInitialFormData = () => {
    if (editingEvent) {
      const minutes = Math.floor(editingEvent.game_clock_time / 60);
      const seconds = editingEvent.game_clock_time % 60;
      return {
        game_id: gameState.id,
        game_clock_period: editingEvent.game_clock_period,
        game_clock_time: editingEvent.game_clock_time,
        minute: minutes,
        second: seconds,
        key: editingEvent.key,
        payload: editingEvent.payload || {},
      };
    }
    return {
      game_id: gameState.id,
      game_clock_period: 1,
      game_clock_time: 0,
      minute: 0,
      second: 0,
      key: EVENT_KEYS.UPDATE_PLAYER_STAT,
      payload: {},
    };
  };

  const [formData, setFormData] = useState(getInitialFormData());

  // Update form data when editingEvent changes
  useEffect(() => {
    setFormData(getInitialFormData());
  }, [editingEvent]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(formData);
  };

  const handleInputChange = (field: string, value: any) => {
    setFormData((prev) => {
      const newData = {
        ...prev,
        [field]: value,
      };

      if (field === 'minute' || field === 'second') {
        const minute = field === 'minute' ? value : prev.minute;
        const second = field === 'second' ? value : prev.second;
        return {
          ...newData,
          game_clock_time: minute * 60 + second,
        };
      }

      return newData;
    });
  };

  return (
    <form onSubmit={handleSubmit}>
      <div className="columns is-multiline">
        <div className="column is-6">
          <div className="field">
            <label className="label">
              {t('basketball.modals.eventLogs.key')}
            </label>
            <div className="control">
              <div className="select is-fullwidth">
                <select
                  value={formData.key}
                  disabled={!!editingEvent}
                  onChange={(e) => handleInputChange('key', e.target.value)}
                >
                  {EVENT_KEYS_EDITABLE.map((key) => (
                    <option key={key} value={key}>
                      {eventKeyToString(key, t)}
                    </option>
                  ))}
                </select>
              </div>
            </div>
          </div>
        </div>
        <div className="column is-2">
          <div className="field">
            <label className="label">
              {t('basketball.modals.eventLogs.game_clock_period')}
            </label>
            <div className="control">
              <div className="select is-fullwidth">
                <select
                  value={formData.game_clock_period}
                  disabled={!!editingEvent}
                  onChange={(e) =>
                    handleInputChange(
                      'game_clock_period',
                      parseInt(e.target.value),
                    )
                  }
                >
                  <option value={1}>Q1</option>
                  <option value={2}>Q2</option>
                  <option value={3}>Q3</option>
                  <option value={4}>Q4</option>
                  <option value={5}>Q5</option>
                  <option value={6}>Q6</option>
                  <option value={7}>Q7</option>
                  <option value={8}>Q8</option>
                  <option value={9}>Q9</option>
                  <option value={10}>Q10</option>
                </select>
              </div>
            </div>
          </div>
        </div>

        <div className="column is-2">
          <div className="field">
            <label className="label">
              {t('basketball.modals.eventLogs.minute')}
            </label>
            <div className="control">
              <input
                className="input"
                type="number"
                min="0"
                max="12"
                disabled={!!editingEvent}
                value={formData.minute}
                onChange={(e) =>
                  handleInputChange('minute', parseInt(e.target.value))
                }
              />
            </div>
          </div>
        </div>

        <div className="column is-2">
          <div className="field">
            <label className="label">
              {t('basketball.modals.eventLogs.second')}
            </label>
            <div className="control">
              <input
                className="input"
                type="number"
                min="0"
                max="59"
                disabled={!!editingEvent}
                value={formData.second}
                onChange={(e) =>
                  handleInputChange('second', parseInt(e.target.value))
                }
              />
            </div>
          </div>
        </div>

        <div className="column is-12">
          <PayloadForm
            eventKey={formData.key}
            initialPayload={formData.payload}
            onPayloadChange={(updateFn: (prevPayload: any) => any) => {
              setFormData((prev) => ({
                ...prev,
                payload: updateFn(prev.payload),
              }));
            }}
            gameState={gameState}
          />
        </div>

        <div className="column is-6">
          <div className="field is-grouped">
            <div className="control">
              <button
                type="submit"
                className={`button is-primary is-small ${
                  isSubmitting ? 'is-loading' : ''
                }`}
                disabled={isSubmitting}
              >
                {editingEvent
                  ? t('basketball.modals.eventLogs.saveEvent')
                  : t('basketball.modals.eventLogs.addEvent')}
              </button>
            </div>
            <div className="control">
              <button
                type="button"
                className="button is-light is-small"
                onClick={onCancel}
              >
                {t('basketball.modals.eventLogs.cancel')}
              </button>
            </div>
          </div>
        </div>

        <div className="column is-6">
          {submitError && (
            <div className="notification is-danger">
              <strong>Error:</strong> {submitError}
            </div>
          )}
        </div>
      </div>
    </form>
  );
}

export default EventLogForm;
