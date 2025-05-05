defmodule GoChampsScoreboard.Sports.Basketball.ReportsTest do
  use ExUnit.Case
  use GoChampsScoreboard.DataCase
  alias GoChampsScoreboard.Sports.Basketball.Reports

  import GoChampsScoreboard.EventsFixtures

  describe "fetch_report_data/2 fiba-scoresheet" do
    test "returns report data" do
      game_state = game_full_event_log_fixture()

      expected_report_data =
        %{
          game_id: game_state.id
        }

      assert expected_report_data == Reports.fetch_report_data("fiba-scoresheet", game_state.id)
    end
  end
end
