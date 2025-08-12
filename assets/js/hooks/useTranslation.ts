import { useTranslation as useReactI18nextTranslation } from 'react-i18next';

export const useTranslation = (namespace?: string) => {
  return useReactI18nextTranslation(namespace);
};

export const useLanguage = () => {
  const { i18n } = useTranslation();

  const changeLanguage = (language: string) => {
    i18n.changeLanguage(language);
  };

  const getCurrentLanguage = () => {
    return i18n.language;
  };

  const isLanguage = (language: string) => {
    return i18n.language === language;
  };

  return {
    currentLanguage: i18n.language,
    changeLanguage,
    getCurrentLanguage,
    isLanguage,
  };
};
