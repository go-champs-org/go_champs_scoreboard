import React, { useState } from 'react';
import Modal from '../../Modal';
import PopUpButton from '../../PopUpButton';
import { GameState, PlayerState, CoachState } from '../../../types';
import { useTranslation } from 'react-i18next';
import debounce from '../../../debounce';

interface FoulsModalProps {
  gameState: GameState;
  showModal: boolean;
  onCloseModal: () => void;
  pushEvent: (event: string, payload: any) => void;
}

type TeamType = 'home' | 'away';
type PersonType = 'player' | 'coach';

interface PersonSelection {
  teamType: TeamType;
  personType: PersonType;
  personId: string;
  person: PlayerState | CoachState;
}

interface TeamSelectorProps {
  selectedTeam: TeamType | null;
  onTeamSelect: (team: TeamType) => void;
  gameState: GameState;
}

function TeamSelector({
  selectedTeam,
  onTeamSelect,
  gameState,
}: TeamSelectorProps) {
  const { t } = useTranslation();

  return (
    <div className="field">
      <label className="label has-text-white-ter">
        {t('basketball.modals.fouls.selectTeam')}
      </label>
      <div className="columns is-gapless">
        <div className="column">
          <button
            className={`button is-fullwidth ${
              selectedTeam === 'home' ? 'is-primary' : 'is-light'
            }`}
            onClick={() => onTeamSelect('home')}
          >
            {gameState.home_team.name || t('basketball.teams.home')}
          </button>
        </div>
        <div className="column">
          <button
            className={`button is-fullwidth ${
              selectedTeam === 'away' ? 'is-primary' : 'is-light'
            }`}
            onClick={() => onTeamSelect('away')}
          >
            {gameState.away_team.name || t('basketball.teams.away')}
          </button>
        </div>
      </div>
    </div>
  );
}

interface PersonTypeSelectorProps {
  disabled?: boolean;
  selectedType: PersonType | null;
  onTypeSelect: (type: PersonType) => void;
}

function PersonTypeSelector({
  disabled = false,
  selectedType,
  onTypeSelect,
}: PersonTypeSelectorProps) {
  const { t } = useTranslation();

  return (
    <div className="field">
      <label className="label has-text-white-ter">
        {t('basketball.modals.fouls.selectPersonType')}
      </label>
      <div className="columns is-gapless">
        <div className="column">
          <button
            className={`button is-fullwidth ${
              selectedType === 'player' ? 'is-info' : 'is-light'
            }`}
            onClick={() => onTypeSelect('player')}
            disabled={disabled}
          >
            {t('basketball.modals.fouls.player')}
          </button>
        </div>
        <div className="column">
          <button
            className={`button is-fullwidth ${
              selectedType === 'coach' ? 'is-info' : 'is-light'
            }`}
            onClick={() => onTypeSelect('coach')}
            disabled={disabled}
          >
            {t('basketball.modals.fouls.coach')}
          </button>
        </div>
      </div>
    </div>
  );
}

interface PersonListProps {
  teamType: TeamType;
  personType: PersonType;
  gameState: GameState;
  onPersonSelect: (person: PlayerState | CoachState) => void;
  selectedPerson: PersonSelection | null;
}

// Mapping from snake_case coach types to translation keys
const COACH_TYPE_TRANSLATION_MAP: Record<string, string> = {
  head_coach: 'headCoach',
  assistant_coach: 'assistantCoach',
};

interface PlayerDisplayNameProps {
  player: PlayerState;
}

function PlayerDisplayName({ player }: PlayerDisplayNameProps) {
  if (player.number) {
    return (
      <>
        {player.number} - {player.name}
      </>
    );
  }
  return <>{player.name}</>;
}

interface CoachDisplayNameProps {
  coach: CoachState;
}

function CoachDisplayName({ coach }: CoachDisplayNameProps) {
  const { t } = useTranslation();

  const coachTypeKey = COACH_TYPE_TRANSLATION_MAP[coach.type] || coach.type;

  return (
    <>
      {coach.name} ({t(`basketball.coaches.types.${coachTypeKey}`)})
    </>
  );
}

interface PersonSelectionPlaceholderProps {
  selectedTeam: TeamType | null;
  selectedPersonType: PersonType | null;
}

function PersonSelectionPlaceholder({
  selectedTeam,
  selectedPersonType,
}: PersonSelectionPlaceholderProps) {
  const { t } = useTranslation();

  return (
    <div className="people-placeholder content has-text-centered">
      <div className="notification is-info is-light">
        <p className="is-size-5 mb-3">
          <span className="icon is-large">
            <i className="fas fa-info-circle fa-2x"></i>
          </span>
        </p>
        <p className="is-size-6">
          {!selectedTeam && (
            <strong>
              {t('basketball.modals.fouls.placeholders.selectTeam')}
            </strong>
          )}
          {selectedTeam && !selectedPersonType && (
            <strong>
              {t('basketball.modals.fouls.placeholders.selectPersonType')}
            </strong>
          )}
        </p>
        <p className="is-size-7 has-text-grey">
          {t('basketball.modals.fouls.placeholders.instruction')}
        </p>
      </div>
    </div>
  );
}

function PersonList({
  teamType,
  personType,
  gameState,
  onPersonSelect,
  selectedPerson,
}: PersonListProps) {
  const { t } = useTranslation();

  const team = teamType === 'home' ? gameState.home_team : gameState.away_team;
  const people = personType === 'player' ? team.players : team.coaches;

  if (!people || people.length === 0) {
    return (
      <div className="notification is-info is-light">
        {t(
          `basketball.modals.fouls.no${
            personType === 'player' ? 'Players' : 'Coaches'
          }`,
        )}
      </div>
    );
  }

  return (
    <div className="field">
      <label className="label has-text-white-ter">
        {t(
          `basketball.modals.fouls.select${
            personType === 'player' ? 'Player' : 'Coach'
          }`,
        )}
      </label>
      <div className="player-list">
        {people.map((person) => {
          const isSelected = selectedPerson?.personId === person.id;

          return (
            <div key={person.id} className="mb-2">
              <button
                className={`button is-fullwidth ${
                  isSelected ? 'is-success' : 'is-light'
                }`}
                onClick={() => onPersonSelect(person)}
              >
                {personType === 'player' ? (
                  <PlayerDisplayName player={person as PlayerState} />
                ) : (
                  <CoachDisplayName coach={person as CoachState} />
                )}
              </button>
            </div>
          );
        })}
      </div>
    </div>
  );
}

// Custom hook for foul update logic
function useFoulUpdate(
  pushEvent: (event: string, payload: any) => void,
  personSelection: PersonSelection | null,
  setPersonSelection: (selection: PersonSelection | null) => void,
) {
  return React.useMemo(
    () =>
      debounce<(foulType: string, metadata?: any) => void>(
        (foulType, metadata) => {
          if (!personSelection) return;

          pushEvent('update-player-stat', {
            ['stat-id']: foulType,
            operation: 'increment',
            ['player-id']: personSelection.personId,
            ['team-type']: personSelection.teamType,
            ...(metadata && { metadata }),
          });

          setPersonSelection(null);
        },
        100,
      ),
    [pushEvent, personSelection, setPersonSelection],
  );
}

interface FoulButtonsProps {
  personSelection: PersonSelection | null;
  onFoulRecord: (foulType: string, metadata?: any) => void;
}

function FoulButtons({ personSelection, onFoulRecord }: FoulButtonsProps) {
  const { t } = useTranslation();

  const isDisabled = !personSelection;
  const personType = personSelection?.personType;

  // Define all possible foul buttons
  const allFoulButtons = [
    // Common fouls for both players and coaches
    {
      key: 'unsportsmanlike',
      statId: 'fouls_unsportsmanlike',
      label: t('basketball.stats.controls.unsportsmanlikeFoul'),
      quickAction: () => onFoulRecord('fouls_unsportsmanlike'),
      availableFor: ['player', 'coach'],
      popUpButtons: [
        {
          label: t('basketball.stats.controls.oneFreeThrow'),
          onClick: () =>
            onFoulRecord('fouls_unsportsmanlike', {
              'free-throws-awarded': '1',
            }),
        },
        {
          label: t('basketball.stats.controls.twoFreeThrows'),
          onClick: () =>
            onFoulRecord('fouls_unsportsmanlike', {
              'free-throws-awarded': '2',
            }),
        },
        {
          label: t('basketball.stats.controls.threeFreeThrows'),
          onClick: () =>
            onFoulRecord('fouls_unsportsmanlike', {
              'free-throws-awarded': '3',
            }),
        },
        {
          label: t('basketball.stats.controls.canceledFreeThrows'),
          onClick: () => onFoulRecord('fouls_unsportsmanlike'),
        },
      ],
    },
    {
      key: 'disqualifying',
      statId: 'fouls_disqualifying',
      label: t('basketball.stats.controls.disqualifyingFoul'),
      quickAction: () => onFoulRecord('fouls_disqualifying'),
      availableFor: ['player', 'coach'],
      popUpButtons: [
        {
          label: t('basketball.stats.controls.oneFreeThrow'),
          onClick: () =>
            onFoulRecord('fouls_disqualifying', { 'free-throws-awarded': '1' }),
        },
        {
          label: t('basketball.stats.controls.twoFreeThrows'),
          onClick: () =>
            onFoulRecord('fouls_disqualifying', { 'free-throws-awarded': '2' }),
        },
        {
          label: t('basketball.stats.controls.threeFreeThrows'),
          onClick: () =>
            onFoulRecord('fouls_disqualifying', { 'free-throws-awarded': '3' }),
        },
        {
          label: t('basketball.stats.controls.canceledFreeThrows'),
          onClick: () => onFoulRecord('fouls_disqualifying'),
        },
      ],
    },
    {
      key: 'gameDisqualifying',
      statId: 'fouls_game_disqualifying',
      label: t('basketball.stats.controls.gameDisqualifyingFoul'),
      quickAction: () => onFoulRecord('fouls_game_disqualifying'),
      availableFor: ['player', 'coach'],
      popUpButtons: [
        {
          label: t('basketball.stats.controls.oneFreeThrow'),
          onClick: () =>
            onFoulRecord('fouls_game_disqualifying', {
              'free-throws-awarded': '1',
            }),
        },
        {
          label: t('basketball.stats.controls.twoFreeThrows'),
          onClick: () =>
            onFoulRecord('fouls_game_disqualifying', {
              'free-throws-awarded': '2',
            }),
        },
        {
          label: t('basketball.stats.controls.threeFreeThrows'),
          onClick: () =>
            onFoulRecord('fouls_game_disqualifying', {
              'free-throws-awarded': '3',
            }),
        },
        {
          label: t('basketball.stats.controls.canceledFreeThrows'),
          onClick: () => onFoulRecord('fouls_game_disqualifying'),
        },
      ],
    },
    // Coach-specific fouls
    {
      key: 'coachTechnical',
      statId: 'fouls_technical',
      label: t('basketball.stats.controls.coachTechnicalFoul'),
      quickAction: () => onFoulRecord('fouls_technical'),
      availableFor: ['coach'],
      popUpButtons: [
        {
          label: t('basketball.stats.controls.oneFreeThrow'),
          onClick: () =>
            onFoulRecord('fouls_technical', { 'free-throws-awarded': '1' }),
        },
        {
          label: t('basketball.stats.controls.twoFreeThrows'),
          onClick: () =>
            onFoulRecord('fouls_technical', { 'free-throws-awarded': '2' }),
        },
        {
          label: t('basketball.stats.controls.canceledFreeThrows'),
          onClick: () => onFoulRecord('fouls_technical'),
        },
      ],
    },
    {
      key: 'benchTechnical',
      statId: 'fouls_technical',
      label: t('basketball.stats.controls.benchTechnicalFoul'),
      quickAction: () =>
        onFoulRecord('fouls_technical', { 'bench-foul': true }),
      availableFor: ['coach'],
      popUpButtons: [
        {
          label: t('basketball.stats.controls.oneFreeThrow'),
          onClick: () =>
            onFoulRecord('fouls_technical', {
              'free-throws-awarded': '1',
              'bench-foul': true,
            }),
        },
        {
          label: t('basketball.stats.controls.twoFreeThrows'),
          onClick: () =>
            onFoulRecord('fouls_technical', {
              'free-throws-awarded': '2',
              'bench-foul': true,
            }),
        },
        {
          label: t('basketball.stats.controls.canceledFreeThrows'),
          onClick: () =>
            onFoulRecord('fouls_technical', { 'bench-foul': true }),
        },
      ],
    },
    // Player-specific fouls
    {
      key: 'fightDisqualifying',
      statId: 'fouls_disqualifying',
      label: t('basketball.stats.controls.fightDisqualifyingFoul'),
      quickAction: () =>
        onFoulRecord('fouls_disqualifying', { 'fight-related': true }),
      availableFor: ['player'],
      popUpButtons: [
        {
          label: t('basketball.stats.controls.oneFreeThrow'),
          onClick: () =>
            onFoulRecord('fouls_disqualifying', {
              'free-throws-awarded': '1',
              'fight-related': true,
            }),
        },
        {
          label: t('basketball.stats.controls.twoFreeThrows'),
          onClick: () =>
            onFoulRecord('fouls_disqualifying', {
              'free-throws-awarded': '2',
              'fight-related': true,
            }),
        },
        {
          label: t('basketball.stats.controls.threeFreeThrows'),
          onClick: () =>
            onFoulRecord('fouls_disqualifying', {
              'free-throws-awarded': '3',
              'fight-related': true,
            }),
        },
        {
          label: t('basketball.stats.controls.canceledFreeThrows'),
          onClick: () =>
            onFoulRecord('fouls_disqualifying', { 'fight-related': true }),
        },
      ],
    },
  ];

  return (
    <div className="field">
      <label className="label has-text-white-ter">
        {t('basketball.modals.fouls.availableFouls')}
      </label>
      <div className="columns is-multiline">
        {allFoulButtons.map((foulButton) => {
          const isButtonDisabled =
            isDisabled ||
            (personType && !foulButton.availableFor.includes(personType));

          return (
            <div key={foulButton.key} className="column is-6">
              <PopUpButton
                onQuickClick={foulButton.quickAction}
                popUpButtons={foulButton.popUpButtons}
                popUpDirection="top"
                className={`button is-stat ${
                  isButtonDisabled ? 'is-light' : 'is-warning'
                }`}
                disabled={isButtonDisabled}
              >
                {foulButton.label}
              </PopUpButton>
            </div>
          );
        })}
      </div>
    </div>
  );
}

function FoulsModal({
  gameState,
  showModal,
  onCloseModal,
  pushEvent,
}: FoulsModalProps) {
  const { t } = useTranslation();
  const [selectedTeam, setSelectedTeam] = useState<TeamType | null>(null);
  const [selectedPersonType, setSelectedPersonType] =
    useState<PersonType | null>(null);
  const [personSelection, setPersonSelection] =
    useState<PersonSelection | null>(null);

  const recordFoul = useFoulUpdate(
    pushEvent,
    personSelection,
    setPersonSelection,
  );

  const handleTeamSelect = (team: TeamType) => {
    setSelectedTeam(team);
    setSelectedPersonType(null);
    setPersonSelection(null);
  };

  const handlePersonTypeSelect = (type: PersonType) => {
    setSelectedPersonType(type);
    setPersonSelection(null);
  };

  const handlePersonSelect = (person: PlayerState | CoachState) => {
    if (!selectedTeam || !selectedPersonType) return;

    setPersonSelection({
      teamType: selectedTeam,
      personType: selectedPersonType,
      personId: person.id,
      person,
    });
  };

  const handleCloseModal = () => {
    setSelectedTeam(null);
    setSelectedPersonType(null);
    setPersonSelection(null);
    onCloseModal();
  };

  return (
    <Modal
      title={t('basketball.modals.fouls.title')}
      showModal={showModal}
      onClose={handleCloseModal}
    >
      <div className="modal-card-body fouls-modal">
        <div className="columns">
          <div className="column is-6">
            <TeamSelector
              selectedTeam={selectedTeam}
              onTeamSelect={handleTeamSelect}
              gameState={gameState}
            />

            <PersonTypeSelector
              disabled={!selectedTeam}
              selectedType={selectedPersonType}
              onTypeSelect={handlePersonTypeSelect}
            />

            <FoulButtons
              personSelection={personSelection}
              onFoulRecord={recordFoul}
            />
          </div>

          <div className="column is-6">
            {selectedTeam && selectedPersonType ? (
              <PersonList
                teamType={selectedTeam}
                personType={selectedPersonType}
                gameState={gameState}
                onPersonSelect={handlePersonSelect}
                selectedPerson={personSelection}
              />
            ) : (
              <PersonSelectionPlaceholder
                selectedTeam={selectedTeam}
                selectedPersonType={selectedPersonType}
              />
            )}
          </div>
        </div>
      </div>
    </Modal>
  );
}

export default FoulsModal;
