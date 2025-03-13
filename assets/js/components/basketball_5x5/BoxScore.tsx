import React from 'react';
import { GameState, TeamState, TeamType } from '../../types';


function formatPercentage(value: number) {
  return `${value.toFixed(0)}%`;
}

interface TableProps {
  team: TeamState;
}

function BasicTable({ team }: TableProps) {
  return (<div className="table-container">
    <table className="table is-fullwidth">
      <thead>
        <tr>
          <th style={{ minWidth: '50px', maxWidth: '50px' }}>#</th>
          <th style={{ minWidth: '140px', maxWidth: '140px' }}>Player</th>
          <th
            className="has-text-centered"
            style={{ minWidth: '80px', maxWidth: '80px' }}
          >
            PTs
          </th>
          <th
            className="has-text-centered"
            style={{ minWidth: '80px', maxWidth: '80px' }}
          >
            ASTs
          </th>
          <th
            className="has-text-centered"
            style={{ minWidth: '80px', maxWidth: '80px' }}
          >
            REBs
          </th>
          <th
            className="has-text-centered"
            style={{ minWidth: '80px', maxWidth: '80px' }}
          >
            STLs
          </th>
          <th
            className="has-text-centered"
            style={{ minWidth: '80px', maxWidth: '80px' }}
          >
            BLKs
          </th>
          <th
            className="has-text-centered"
            style={{ minWidth: '80px', maxWidth: '80px' }}
          >
            1 PT
          </th>

          <th
            className="has-text-centered"
            style={{ minWidth: '80px', maxWidth: '80px' }}
          >
            2 PTs
          </th>

          <th
            className="has-text-centered"
            style={{ minWidth: '80px', maxWidth: '80px' }}
          >
            3 PTs
          </th>
        </tr>
      </thead>
      <tbody>
        {team.players.map((player) => (
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
            <td className="has-text-centered">{player.stats_values['free_throws_made']}</td>
            <td className="has-text-centered">{player.stats_values['field_goals_made']}</td>
            <td className="has-text-centered">{player.stats_values['three_point_field_goals_made']}</td>
          </tr>
        ))}
      </tbody>
    </table>
  </div>
  );
}

function MediumTable({ team }: TableProps) {
  return (
    <div className="table-container">
      <table className="table is-fullwidth">
        <thead>
          <tr>
            <th style={{ minWidth: '50px', maxWidth: '50px' }}>#</th>
            <th style={{ minWidth: '140px', maxWidth: '140px' }}>Player</th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              PTs
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              ASTs
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              REBs
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              STLs
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              BLKs
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              TOs
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              P. FLTs
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              F. FLTs
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              T. FLTs
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              1 PT
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              1 PT %
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              2 PTs
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              2 PT %
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              3 PTs
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              3 PT %
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              REB. O
            </th>
            <th
              className="has-text-centered"
              style={{ minWidth: '80px', maxWidth: '80px' }}
            >
              REB. D
            </th>
          </tr>
        </thead>
        <tbody>
          {team.players.map((player) => (
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
                {player.stats_values['fouls_flagrant']}
              </td>
              <td className="has-text-centered">
                {player.stats_values['fouls_technical']}
              </td>
              <td className="has-text-centered">{`${player.stats_values['free_throws_made']} / ${player.stats_values['free_throws_attempted']}`}</td>
              <td className="has-text-centered">
                {formatPercentage(
                  player.stats_values['free_throw_percentage'],
                )}
              </td>
              <td className="has-text-centered">{`${player.stats_values['field_goals_made']} / ${player.stats_values['field_goals_attempted']}`}</td>
              <td className="has-text-centered">
                {formatPercentage(
                  player.stats_values['field_goal_percentage'],
                )}
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
        {game_state.view_settings_state.view === 'basketball-basic' ? (
          <BasicTable team={selectedTeam} />
        ) : (
          <MediumTable team={selectedTeam} />
        )}
      </div>
    </div>
  );
}

export default BoxScore;
