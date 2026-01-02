import { COACH_TYPE_LABELS } from './constants';

export const selectCoachTypeLabelKey = (coachType: string) => {
  const coach = COACH_TYPE_LABELS[coachType];
  return coach ? coach : coachType;
};
