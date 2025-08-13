import { TFunction } from 'i18next';
import { keyToEventTypeKey } from '../basketball_5x5/Events/keyMapper';

export function eventKeyToString(key: string, t: TFunction) {
  const eventTranslationKey = keyToEventTypeKey(key);
  return t(eventTranslationKey);
}
