import React from 'react';
import { useTranslation } from 'react-i18next';
import { boxScorePlayerStats } from '../../selectors';
import { View, Text } from '@react-pdf/renderer';

function Legend() {
  const { t } = useTranslation();
  const playerStats = boxScorePlayerStats();

  return (
    <View>
      <View
        style={{
          flexDirection: 'row',
          flexWrap: 'wrap',
          marginBottom: 4,
          fontWeight: 'bold',
        }}
      >
        <Text>{t('basketball.reports.fibaBoxScore.legend')}</Text>
      </View>
      {playerStats.map((stat, index) => (
        <View
          key={index}
          style={{ flexDirection: 'row', flexWrap: 'wrap', marginBottom: 1 }}
        >
          <Text style={{ fontWeight: 'bold' }}>
            {stat.abbreviationTranslationKey
              ? `${t(stat.abbreviationTranslationKey)}:`
              : `${stat.key}:`}
          </Text>
          <Text style={{ marginLeft: 4 }}>
            {t(stat.descriptionTranslationKey)}
          </Text>
        </View>
      ))}
    </View>
  );
}

export default Legend;
