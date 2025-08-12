import React from 'react';
import { useTranslation } from 'react-i18next';

const LanguageSwitcher: React.FC = () => {
  const { i18n } = useTranslation();

  const handleLanguageChange = (
    event: React.ChangeEvent<HTMLSelectElement>,
  ) => {
    i18n.changeLanguage(event.target.value);
  };

  return (
    <div className="language-switcher">
      <div className="select is-small">
        <select value={i18n.language} onChange={handleLanguageChange}>
          <option value="en">English</option>
          <option value="pt-BR">Português (BR)</option>
        </select>
      </div>
    </div>
  );
};

export default LanguageSwitcher;
