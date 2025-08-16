import React from 'react';
import { useTranslation } from 'react-i18next';
import { GameState } from '../../../types';
import Modal from '../../Modal';
import AddOfficialRow from './AddOfficialRow';
import EditOfficialRow from './EditOfficialRow';

interface OfficialsTableProps {
  game_state: GameState;
  showAddOfficialRow: boolean;
  pushEvent: (event: string, data: any) => void;
  setShowAddOfficialRow: (show: boolean) => void;
}

function OfficialsTable({
  game_state,
  showAddOfficialRow,
  pushEvent,
  setShowAddOfficialRow,
}: OfficialsTableProps) {
  const { t } = useTranslation();
  return (
    <div>
      <div className="table-container">
        <table className="table is-fullwidth">
          <thead>
            <tr>
              <th style={{ minWidth: '140px', maxWidth: '140px' }}>
                {t('basketball.officials.modal.name')}
              </th>
              <th style={{ minWidth: '140px', maxWidth: '140px' }}>
                {t('basketball.officials.modal.type')}
              </th>
              <th style={{ minWidth: '65px', maxWidth: '65px' }}>
                {t('basketball.officials.modal.licenseNumber')}
              </th>
              <th style={{ minWidth: '65px', maxWidth: '65px' }}>
                {t('basketball.officials.modal.federation')}
              </th>
              <th style={{ minWidth: '50px', maxWidth: '50px' }}>
                {t('basketball.officials.modal.edit')}
              </th>
              <th style={{ minWidth: '50px', maxWidth: '50px' }}>
                {t('basketball.officials.modal.delete')}
              </th>
            </tr>
          </thead>
          <tbody>
            {showAddOfficialRow && (
              <AddOfficialRow
                pushEvent={pushEvent}
                onConfirmAction={() => setShowAddOfficialRow(false)}
              />
            )}
            {game_state.officials.map((official) => (
              <EditOfficialRow
                key={official.id}
                official={official}
                pushEvent={pushEvent}
              />
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

interface EditOfficialsModalProps {
  game_state: GameState;
  showModal: boolean;
  onCloseModal: () => void;
  pushEvent: (event: string, payload: any) => void;
}

function EditOfficialsModal({
  onCloseModal,
  showModal,
  game_state,
  pushEvent,
}: EditOfficialsModalProps) {
  const { t } = useTranslation();
  const [showAddOfficialRow, setShowAddOfficialRow] = React.useState(false);
  return (
    <Modal
      title={t('basketball.officials.modal.title')}
      onClose={onCloseModal}
      showModal={showModal}
      modalCardStyle={{ width: '800px' }}
    >
      <div className="columns is-multiline">
        <div className="column is-12 has-text-right">
          <button
            className="button is-info is-small"
            onClick={() => setShowAddOfficialRow(true)}
          >
            {t('basketball.officials.modal.addOfficial')}
          </button>
        </div>

        <div className="column is-12">
          <OfficialsTable
            game_state={game_state}
            showAddOfficialRow={showAddOfficialRow}
            pushEvent={pushEvent}
            setShowAddOfficialRow={setShowAddOfficialRow}
          />
        </div>
      </div>
    </Modal>
  );
}

export default EditOfficialsModal;
