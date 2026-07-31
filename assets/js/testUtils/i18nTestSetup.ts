// Minimal i18next initialization for the "pdf-render" Jest project
// (assets/js/components/basketball_5x5/Reports/__pdf_tests__).
//
// The app's real bootstrap (assets/js/i18n/index.ts) also wires up
// i18next-browser-languagedetector, which reads browser globals
// (localStorage/navigator/document) that don't exist in this project's
// `testEnvironment: 'node'`. Without *some* i18next init, react-i18next's
// `useTranslation()` falls back to returning raw translation keys, which
// would make the extracted PDF text unreadable and the snapshot far less
// useful as a regression check. This sets up the same translation
// resources, pinned to English, without the browser-only detector.
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import en from '../i18n/locales/en.json';
import pt from '../i18n/locales/pt.json';

i18n.use(initReactI18next).init({
  resources: {
    en: { translation: en },
    'pt-BR': { translation: pt },
  },
  lng: 'en',
  fallbackLng: 'en',
  interpolation: {
    escapeValue: false,
  },
});

export default i18n;
