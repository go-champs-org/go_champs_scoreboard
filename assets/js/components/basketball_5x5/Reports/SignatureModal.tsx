import React from 'react';
import { useTranslation } from 'react-i18next';
import SignatureCanvas from 'react-signature-canvas';

import { GameState, TeamType, OfficialState } from '../../../types';
import Modal from '../../Modal';
import { selectOfficialLabelKey } from '../Officials/selectors';
import { COACH_TYPE_LABELS } from '../Coaches/constants';

interface SignatureModalProps {
  game_state: GameState;
  showModal: boolean;
  onCloseModal: () => void;
  pushEvent: (event: string, data: any) => void;
}

type SignatureTab = 'officials' | 'coaches' | 'players';

interface SignaturePadProps {
  onSave: (signature: string) => void;
  onCancel: () => void;
}

function SignaturePad({ onSave, onCancel }: SignaturePadProps) {
  const { t } = useTranslation();
  const sigCanvas = React.useRef<SignatureCanvas>(null);

  const handleSave = () => {
    if (sigCanvas.current && !sigCanvas.current.isEmpty()) {
      debugger;
      try {
        const trimmedCanvas = sigCanvas.current.getTrimmedCanvas();
        const signature = trimmedCanvas.toDataURL('image/png');
        onSave(signature);
      } catch (error) {
        // Fallback to regular canvas if getTrimmedCanvas fails
        const signature = sigCanvas.current.toDataURL('image/png');
        onSave(signature);
      }
    }
  };

  const handleClear = () => {
    sigCanvas.current?.clear();
  };

  return (
    <>
      <div className="signature-pad-container">
        <div className="box">
          <SignatureCanvas
            ref={sigCanvas}
            penColor="black"
            canvasProps={{
              width: 400,
              height: 200,
              className: 'signature-canvas',
              style: { border: '1px solid #ccc' },
            }}
          />
        </div>
      </div>
      <div className="buttons is-right mt-3">
        <button className="button is-small is-light" onClick={handleClear}>
          {t('basketball.modals.signatures.actions.clear')}
        </button>
        <button className="button is-small is-light" onClick={onCancel}>
          {t('basketball.modals.signatures.actions.cancel')}
        </button>
        <button className="button is-small is-primary" onClick={handleSave}>
          {t('basketball.modals.signatures.actions.save')}
        </button>
      </div>
    </>
  );
}

interface OfficialsTabProps {
  officials: OfficialState[];
  pushEvent: (event: string, data: any) => void;
}

function OfficialsTab({ officials, pushEvent }: OfficialsTabProps) {
  const { t } = useTranslation();
  const [showSignaturePad, setShowSignaturePad] = React.useState<string | null>(
    null,
  );

  const handleSignatureSave = (officialId: string, signature: string) => {
    pushEvent('update-official-in-game', {
      id: officialId,
      signature: signature,
    });
    setShowSignaturePad(null);
  };

  const handleSignatureClear = (officialId: string) => {
    pushEvent('update-official-in-game', {
      id: officialId,
      signature: null,
    });
  };

  if (showSignaturePad) {
    return (
      <SignaturePad
        onSave={(signature) => handleSignatureSave(showSignaturePad, signature)}
        onCancel={() => setShowSignaturePad(null)}
      />
    );
  }

  return (
    <div>
      <h4 className="title is-5 mb-4">
        {t('basketball.modals.signatures.officials')}
      </h4>
      {officials.length === 0 ? (
        <p className="has-text-grey">
          {t('basketball.modals.signatures.noOfficials')}
        </p>
      ) : (
        <div className="table-container">
          <table className="table is-fullwidth is-narrow">
            <thead>
              <tr>
                <th>{t('basketball.officials.modal.name')}</th>
                <th>{t('basketball.officials.modal.type')}</th>
                <th>{t('basketball.modals.signatures.status')}</th>
                <th>{t('basketball.modals.signatures.actionsHeader')}</th>
              </tr>
            </thead>
            <tbody>
              {officials.map((official) => (
                <tr key={official.id}>
                  <td>{official.name}</td>
                  <td>{t(selectOfficialLabelKey(official.type))}</td>
                  <td>
                    {official.signature ? (
                      <span className="tag is-success">
                        <i className="fas fa-check mr-1"></i>
                        {t('basketball.modals.signatures.signed')}
                      </span>
                    ) : (
                      <span className="tag is-warning">
                        {t('basketball.modals.signatures.pending')}
                      </span>
                    )}
                  </td>
                  <td>
                    {official.signature ? (
                      <button
                        className="button is-small is-danger"
                        onClick={() => handleSignatureClear(official.id)}
                      >
                        {t('basketball.modals.signatures.actions.clear')}
                      </button>
                    ) : (
                      <button
                        className="button is-small is-primary"
                        onClick={() => setShowSignaturePad(official.id)}
                      >
                        {t('basketball.modals.signatures.actions.sign')}
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

interface CoachesTabProps {
  game_state: GameState;
  pushEvent: (event: string, data: any) => void;
}

function CoachesTab({ game_state, pushEvent }: CoachesTabProps) {
  const { t } = useTranslation();
  const [activeTeam, setActiveTeam] = React.useState<TeamType>('home');
  const [showSignaturePad, setShowSignaturePad] = React.useState<string | null>(
    null,
  );

  const selectedTeam =
    activeTeam === 'away' ? game_state.away_team : game_state.home_team;

  const handleSignatureSave = (coachId: string, signature: string) => {
    pushEvent('update-coach-in-team', {
      'team-type': activeTeam,
      coach: {
        id: coachId,
        signature: signature,
      },
    });
    setShowSignaturePad(null);
  };

  const handleSignatureClear = (coachId: string) => {
    pushEvent('update-coach-in-team', {
      'team-type': activeTeam,
      coach: {
        id: coachId,
        signature: null,
      },
    });
  };

  if (showSignaturePad) {
    return (
      <SignaturePad
        onSave={(signature) => handleSignatureSave(showSignaturePad, signature)}
        onCancel={() => setShowSignaturePad(null)}
      />
    );
  }

  return (
    <div>
      <h4 className="title is-5 mb-4">
        {t('basketball.modals.signatures.coaches')}
      </h4>

      <div className="tabs is-boxed mb-4">
        <ul>
          <li className={activeTeam === 'home' ? 'is-active' : ''}>
            <a onClick={() => setActiveTeam('home')}>
              <span>{game_state.home_team.name}</span>
            </a>
          </li>
          <li className={activeTeam === 'away' ? 'is-active' : ''}>
            <a onClick={() => setActiveTeam('away')}>
              <span>{game_state.away_team.name}</span>
            </a>
          </li>
        </ul>
      </div>

      {selectedTeam.coaches.length === 0 ? (
        <p className="has-text-grey">
          {t('basketball.modals.signatures.noCoaches')}
        </p>
      ) : (
        <div className="table-container">
          <table className="table is-fullwidth is-narrow">
            <thead>
              <tr>
                <th>{t('basketball.coaches.modal.name')}</th>
                <th>{t('basketball.coaches.modal.type')}</th>
                <th>{t('basketball.modals.signatures.status')}</th>
                <th>{t('basketball.modals.signatures.actionsHeader')}</th>
              </tr>
            </thead>
            <tbody>
              {selectedTeam.coaches.map((coach) => (
                <tr key={coach.id}>
                  <td>{coach.name}</td>
                  <td>{t(COACH_TYPE_LABELS[coach.type])}</td>
                  <td>
                    {coach.signature ? (
                      <span className="tag is-success">
                        <i className="fas fa-check mr-1"></i>
                        {t('basketball.modals.signatures.signed')}
                      </span>
                    ) : (
                      <span className="tag is-warning">
                        {t('basketball.modals.signatures.pending')}
                      </span>
                    )}
                  </td>
                  <td>
                    {coach.signature ? (
                      <button
                        className="button is-small is-danger"
                        onClick={() => handleSignatureClear(coach.id)}
                      >
                        {t('basketball.modals.signatures.actions.clear')}
                      </button>
                    ) : (
                      <button
                        className="button is-small is-primary"
                        onClick={() => setShowSignaturePad(coach.id)}
                      >
                        {t('basketball.modals.signatures.actions.sign')}
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

interface PlayersTabProps {
  game_state: GameState;
  pushEvent: (event: string, data: any) => void;
}

function PlayersTab({ game_state, pushEvent }: PlayersTabProps) {
  const { t } = useTranslation();
  const [activeTeam, setActiveTeam] = React.useState<TeamType>('home');
  const [showSignaturePad, setShowSignaturePad] = React.useState<string | null>(
    null,
  );

  const selectedTeam =
    activeTeam === 'away' ? game_state.away_team : game_state.home_team;

  const handleSignatureSave = (playerId: string, signature: string) => {
    pushEvent('update-player-in-team', {
      'team-type': activeTeam,
      player: {
        id: playerId,
        signature: signature,
      },
    });
    setShowSignaturePad(null);
  };

  const handleSignatureClear = (playerId: string) => {
    pushEvent('update-player-in-team', {
      'team-type': activeTeam,
      player: {
        id: playerId,
        signature: null,
      },
    });
  };

  if (showSignaturePad) {
    return (
      <SignaturePad
        onSave={(signature) => handleSignatureSave(showSignaturePad, signature)}
        onCancel={() => setShowSignaturePad(null)}
      />
    );
  }

  return (
    <div>
      <h4 className="title is-5 mb-4">
        {t('basketball.modals.signatures.players')}
      </h4>

      <div className="tabs is-boxed mb-4">
        <ul>
          <li className={activeTeam === 'home' ? 'is-active' : ''}>
            <a onClick={() => setActiveTeam('home')}>
              <span>{game_state.home_team.name}</span>
            </a>
          </li>
          <li className={activeTeam === 'away' ? 'is-active' : ''}>
            <a onClick={() => setActiveTeam('away')}>
              <span>{game_state.away_team.name}</span>
            </a>
          </li>
        </ul>
      </div>

      {selectedTeam.players.length === 0 ? (
        <p className="has-text-grey">
          {t('basketball.modals.signatures.noPlayers')}
        </p>
      ) : (
        <div className="table-container">
          <table className="table is-fullwidth is-narrow">
            <thead>
              <tr>
                <th>#</th>
                <th>{t('basketball.players.modal.name')}</th>
                <th>{t('basketball.modals.signatures.status')}</th>
                <th>{t('basketball.modals.signatures.actionsHeader')}</th>
              </tr>
            </thead>
            <tbody>
              {selectedTeam.players.map((player) => (
                <tr key={player.id}>
                  <td>{player.number}</td>
                  <td>
                    {player.name}
                    {player.is_captain && (
                      <span className="tag is-info is-light ml-2">
                        {t('basketball.players.modal.captain')}
                      </span>
                    )}
                  </td>
                  <td>
                    {player.signature ? (
                      <span className="tag is-success">
                        <i className="fas fa-check mr-1"></i>
                        {t('basketball.modals.signatures.signed')}
                      </span>
                    ) : (
                      <span className="tag is-warning">
                        {t('basketball.modals.signatures.pending')}
                      </span>
                    )}
                  </td>
                  <td>
                    {player.signature ? (
                      <button
                        className="button is-small is-danger"
                        onClick={() => handleSignatureClear(player.id)}
                      >
                        {t('basketball.modals.signatures.actions.clear')}
                      </button>
                    ) : (
                      <button
                        className="button is-small is-primary"
                        onClick={() => setShowSignaturePad(player.id)}
                      >
                        {t('basketball.modals.signatures.actions.sign')}
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function SignatureModal({
  game_state,
  showModal,
  onCloseModal,
  pushEvent,
}: SignatureModalProps) {
  const { t } = useTranslation();
  const [activeTab, setActiveTab] = React.useState<SignatureTab>('officials');

  return (
    <Modal
      title={t('basketball.modals.signatures.title')}
      showModal={showModal}
      onClose={onCloseModal}
      modalCardStyle={{ width: '1024px' }}
    >
      <div className="signature-modal">
        <div className="tabs is-boxed">
          <ul>
            <li className={activeTab === 'officials' ? 'is-active' : ''}>
              <a onClick={() => setActiveTab('officials')}>
                <span>{t('basketball.modals.signatures.officials')}</span>
              </a>
            </li>
            <li className={activeTab === 'coaches' ? 'is-active' : ''}>
              <a onClick={() => setActiveTab('coaches')}>
                <span>{t('basketball.modals.signatures.coaches')}</span>
              </a>
            </li>
            <li className={activeTab === 'players' ? 'is-active' : ''}>
              <a onClick={() => setActiveTab('players')}>
                <span>{t('basketball.modals.signatures.players')}</span>
              </a>
            </li>
          </ul>
        </div>

        <div className="tab-content mt-4">
          {activeTab === 'officials' && (
            <OfficialsTab
              officials={game_state.officials}
              pushEvent={pushEvent}
            />
          )}
          {activeTab === 'coaches' && (
            <CoachesTab game_state={game_state} pushEvent={pushEvent} />
          )}
          {activeTab === 'players' && (
            <PlayersTab game_state={game_state} pushEvent={pushEvent} />
          )}
        </div>
      </div>
    </Modal>
  );
}

export default SignatureModal;
