import React from 'react';
import { CoachState } from '../../../types';
import { useTranslation } from 'react-i18next';

interface DisplayCoachProps {
  coach: CoachState;
}

export default function DisplayCoach({ coach }: DisplayCoachProps) {
  const { t } = useTranslation();

  const coachTypeKey =
    coach.type === 'head_coach'
      ? 'basketball.coaches.types.headCoachShort'
      : 'basketball.coaches.types.assistantCoachShort';

  return (
    <>
      {t(coachTypeKey)} {coach.name}
    </>
  );
}
