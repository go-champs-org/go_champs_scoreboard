import React from 'react';
import { useTranslation } from 'react-i18next';
import { GameState, TeamState, TeamType } from '../../types';
import { BASKETBALL_VIEWS } from './constants';
import { useSelectedView } from '../../shared/ViewSettingsContext';

function formatPercentage(value: number) {
  return `${value.toFixed(0)}%`;
}

interface TableProps {
  team: TeamState;
}

function boxScorePlayers(team: TeamState) {
  return team.players.filter((player) => player.state !== 'not_available');
}

function BasicTable({ team }: TableProps) {
  const { t } = useTranslation();
  return (
    <div className="table-container">
      <table className="table is-fullwidth">
        <thead>
          <tr>
            <th style={{ minWidth: '50px', maxWidth: '50px' }}>#</th>
            <th style={{ minWidth: '140px', maxWidth: '140px' }}>
              {t('basketball.stats.abbreviations.player')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.points')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.assists')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.rebounds')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.steals')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.blocks')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.onePoint')}
            </th>

            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.twoPoints')}
            </th>

            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.threePoints')}
            </th>
          </tr>
        </thead>
        <tbody>
          {boxScorePlayers(team).map((player) => (
            <tr key={player.id}>
              <td>{player.number}</td>
              <td>{player.name}</td>
              <td className="has-text-centered">
                {player.stats_values['points']}
              </td>
              <td className="has-text-centered">
                {player.stats_values['assists']}
              </td>
              <td className="has-text-centered">
                {player.stats_values['rebounds']}
              </td>
              <td className="has-text-centered">
                {player.stats_values['steals']}
              </td>
              <td className="has-text-centered">
                {player.stats_values['blocks']}
              </td>
              <td className="has-text-centered">
                {player.stats_values['free_throws_made']}
              </td>
              <td className="has-text-centered">
                {player.stats_values['field_goals_made']}
              </td>
              <td className="has-text-centered">
                {player.stats_values['three_point_field_goals_made']}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function MediumTable({ team }: TableProps) {
  const { t } = useTranslation();
  return (
    <div className="table-container">
      <table className="table is-fullwidth">
        <thead>
          <tr>
            <th style={{ minWidth: '50px', maxWidth: '50px' }}>#</th>
            <th style={{ minWidth: '140px', maxWidth: '140px' }}>
              {t('basketball.stats.abbreviations.player')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.points')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.assists')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.rebounds')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.steals')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.blocks')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.turnovers')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.personalFouls')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.flagrantFouls')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.technicalFouls')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.onePoint')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.onePointPercentage')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.twoPoints')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.twoPointPercentage')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.threePoints')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.threePointPercentage')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.offensiveRebounds')}
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              {t('basketball.stats.abbreviations.defensiveRebounds')}
            </th>
          </tr>
        </thead>
        <tbody>
          {boxScorePlayers(team).map((player) => (
            <tr key={player.id}>
              <td>{player.number}</td>
              <td>{player.name}</td>
              <td className="has-text-centered">
                {player.stats_values['points']}
              </td>
              <td className="has-text-centered">
                {player.stats_values['assists']}
              </td>
              <td className="has-text-centered">
                {player.stats_values['rebounds']}
              </td>
              <td className="has-text-centered">
                {player.stats_values['steals']}
              </td>
              <td className="has-text-centered">
                {player.stats_values['blocks']}
              </td>
              <td className="has-text-centered">
                {player.stats_values['turnovers']}
              </td>
              <td className="has-text-centered">
                {player.stats_values['fouls_personal']}
              </td>
              <td className="has-text-centered">
                {player.stats_values['fouls_unsportsmanlike']}
              </td>
              <td className="has-text-centered">
                {player.stats_values['fouls_technical']}
              </td>
              <td className="has-text-centered">{`${player.stats_values['free_throws_made']} / ${player.stats_values['free_throws_attempted']}`}</td>
              <td className="has-text-centered">
                {formatPercentage(player.stats_values['free_throw_percentage'])}
              </td>
              <td className="has-text-centered">{`${player.stats_values['field_goals_made']} / ${player.stats_values['field_goals_attempted']}`}</td>
              <td className="has-text-centered">
                {formatPercentage(player.stats_values['field_goal_percentage'])}
              </td>
              <td className="has-text-centered">{`${player.stats_values['three_point_field_goals_made']} / ${player.stats_values['three_point_field_goals_attempted']}`}</td>
              <td className="has-text-centered">
                {formatPercentage(
                  player.stats_values['three_point_field_goal_percentage'],
                )}
              </td>
              <td className="has-text-centered">
                {player.stats_values['rebounds_offensive']}
              </td>
              <td className="has-text-centered">
                {player.stats_values['rebounds_defensive']}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

interface BoxScoreProps {
  game_state: GameState;
}

function BoxScore({ game_state }: BoxScoreProps) {
  const [activeTab, setActiveTab] = React.useState('away' as TeamType);
  const selectedTeam =
    activeTab === 'away' ? game_state.away_team : game_state.home_team;
  const selectedView = useSelectedView();

  return (
    <div className="columns is-multiline">
      <div className="column is-12">
        <div className="tabs is-boxed">
          <ul>
            <li className={activeTab === 'away' ? 'is-active' : ''}>
              <a onClick={() => setActiveTab('away')}>
                <span>{game_state.away_team.name}</span>
              </a>
            </li>
            <li className={activeTab === 'home' ? 'is-active' : ''}>
              <a onClick={() => setActiveTab('home')}>
                <span>{game_state.home_team.name}</span>
              </a>
            </li>
          </ul>
        </div>
      </div>

      <div className="column is-12">
        {selectedView === BASKETBALL_VIEWS.BASIC ? (
          <BasicTable team={selectedTeam} />
        ) : (
          <MediumTable team={selectedTeam} />
        )}
      </div>
    </div>
  );
}

export default BoxScore;
