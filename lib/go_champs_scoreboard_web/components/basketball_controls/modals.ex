defmodule Components.BasketballControls.Modals do
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  alias GoChampsScoreboard.Games.Teams

  def add_new_player(assigns) do
    ~H"""
    <GoChampsScoreboardWeb.CoreComponents.modal id="add_new_player">
      <.form for={@add_new_player_form} class="form" phx-submit="add-player-to-team">
        <header class="modal-card-head">
          <p class="modal-card-title">Add player to <%= @selected_team %></p>
        </header>
        <section class="modal-card-body">
          <div class="field is-grouped">
            <div class="control is-expanded">
              <GoChampsScoreboardWeb.CoreComponents.input
                label="Name"
                type="text"
                field={@add_new_player_form[:name]}
              />
            </div>

            <div class="control">
              <GoChampsScoreboardWeb.CoreComponents.input
                label="Number"
                type="number"
                field={@add_new_player_form[:number]}
              />
            </div>

            <GoChampsScoreboardWeb.CoreComponents.input
              type="hidden"
              value={@selected_team}
              field={@add_new_player_form[:team_type]}
            />
          </div>
        </section>
        <footer class="modal-card-foot">
          <div class="buttons">
            <button class="button is-success" type="submit">Save changes</button>
            <button class="button">Cancel</button>
          </div>
        </footer>
      </.form>
    </GoChampsScoreboardWeb.CoreComponents.modal>
    """
  end

  def team_box_score(assigns) do
    ~H"""
    <GoChampsScoreboardWeb.CoreComponents.modal id="team_box_score" content_style="width: 900px">
      <header class="modal-card-head">
        <p class="modal-card-title">Box score for <%= @selected_team %></p>
      </header>
      <section class="modal-card-body">
        <table class="table is-fullwidth">
          <thead>
            <tr>
              <th>#</th>
              <th>Name</th>
              <th>Points</th>
              <th>3 FGs</th>
              <th>2 FGs</th>
              <th>F. Thr</th>
              <th>Assits</th>
              <th>D. Reb</th>
              <th>O. Reb</th>
              <th>T. Reb</th>
              <th>Steals</th>
              <th>Blocks</th>
              <th>TO</th>
            </tr>
          </thead>
          <tbody>
            <%= if @selected_team != "" do %>
              <%= for player <- Teams.list_players(@game_state, @selected_team) do %>
                <tr>
                  <td><%= player.number %></td>
                  <td><%= player.name %></td>
                  <td><%= Map.get(player.stats_values, "points", 0) %></td>
                  <td><%= Map.get(player.stats_values, "three-points-made", 0) %></td>
                  <td><%= Map.get(player.stats_values, "two-points-made", 0) %></td>
                  <td><%= Map.get(player.stats_values, "one-points-made", 0) %></td>
                  <td><%= Map.get(player.stats_values, "assists", 0) %></td>
                  <td><%= Map.get(player.stats_values, "def-rebounds", 0) %></td>
                  <td><%= Map.get(player.stats_values, "off-rebounds", 0) %></td>
                  <td><%= Map.get(player.stats_values, "rebounds", 0) %></td>
                  <td><%= Map.get(player.stats_values, "steals", 0) %></td>
                  <td><%= Map.get(player.stats_values, "blocks", 0) %></td>
                  <td><%= Map.get(player.stats_values, "tournovers", 0) %></td>
                </tr>
              <% end %>
            <% else %>
              <p>No team selected.</p>
            <% end %>
          </tbody>
        </table>
      </section>
      <footer class="modal-card-foot">
      </footer>
    </GoChampsScoreboardWeb.CoreComponents.modal>
    """
  end

  def modals(assigns) do
    ~H"""
    <.add_new_player
      add_new_player_form={@add_new_player_form}
      game_state={@game_state}
      selected_player={@selected_player}
      selected_team={@selected_team}
    />
    <.team_box_score game_state={@game_state} selected_team={@selected_team} />
    """
  end
end
