import { OFFICIAL_TYPES } from './constants';

export const selectOfficialLabelKey = (officialType: string) => {
  const official = OFFICIAL_TYPES.find((t) => t.value === officialType);
  return official ? official.labelKey : officialType;
};
