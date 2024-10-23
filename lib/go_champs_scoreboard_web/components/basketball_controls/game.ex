defmodule Components.BasketballControls.Game do
  use Phoenix.Component

  def format_time(seconds) when is_integer(seconds) and seconds >= 0 do
    minutes = div(seconds, 60)
    remaining_seconds = rem(seconds, 60)

    formatted_minutes = pad_zero(minutes)
    formatted_seconds = pad_zero(remaining_seconds)

    "#{formatted_minutes}:#{formatted_seconds}"
  end

  defp pad_zero(number) when number < 10 do
    "0#{number}"
  end

  defp pad_zero(number), do: "#{number}"

  def time_controls(assigns) do
    ~H"""
    <div class="columns is-multiline">
      <div class="column is-12 has-text-centered">
        <button class="button">
          <%= "<" %>
        </button>

        <button class="button">
          <%= @game_state.clock_state.period %>
        </button>

        <button class="button">
          <%= ">" %>
        </button>
      </div>

      <div class="column is-12 has-text-centered">
        <button class="button">
          <%= "<" %>
        </button>

        <button class="button">
          <%= format_time(@game_state.clock_state.time) %>
        </button>

        <button class="button">
          <%= ">" %>
        </button>
      </div>

      <div class="column is-12 has-text-centered">
        <button class="button" phx-click="update-clock-state" phx-value-state="running">
          Start
        </button>

        <button class="button" phx-click="update-clock-state" phx-value-state="paused">
          Pause
        </button>
      </div>
    </div>
    """
  end

  def home_team_totals(assigns) do
    ~H"""
    <div class="columns is-multiline">
      <div class="column is-12">
        <button class="button">
          Undo
        </button>

        <button class="button">
          T. Foul
        </button>
      </div>

      <div class="column is-12 has-text-right">
        <button class="button" phx-click="show-team-box-score" phx-value-team-type="home">
          Box score
        </button>

        <button class="button is-large" phx-click="select-team" phx-value-team-type="home">
          <%= @game_state.home_team.name %>
        </button>

        <button class="button is-large">
          0
        </button>
      </div>
    </div>
    """
  end

  def away_team_totals(assigns) do
    ~H"""
    <div class="columns is-multiline">
      <div class="column is-12">
        <Components.BasketballControls.Game.live_controls game_state={@game_state} />
      </div>

      <div class="column is-12">
        <button class="button is-large">
          0
        </button>

        <button class="button is-large" phx-click="select-team" phx-value-team-type="away">
          <%= @game_state.away_team.name %>
        </button>

        <button class="button" phx-click="show-team-box-score" phx-value-team-type="away">
          Box score
        </button>
      </div>
    </div>
    """
  end

  def live_controls(assigns) do
    ~H"""
    <div class="live-mode"></div>

    <button class="button" phx-click="start-live-mode">
      Start live
    </button>

    <button class="button" phx-click="end-live-mode">
      End live
    </button>
    """
  end

  def main(assigns) do
    ~H"""
    <div class="columns is-multiline">
      <div class="column is-12">
        <div class="columns">
          <div class="column is-4">
            <Components.BasketballControls.Game.home_team_totals game_state={@game_state} />
          </div>

          <div class="column is-4 has-text-centered">
            <Components.BasketballControls.Game.time_controls game_state={@game_state} />
          </div>

          <div class="column is-4">
            <Components.BasketballControls.Game.away_team_totals game_state={@game_state} />
          </div>
        </div>
      </div>
    </div>
    """
  end
end
