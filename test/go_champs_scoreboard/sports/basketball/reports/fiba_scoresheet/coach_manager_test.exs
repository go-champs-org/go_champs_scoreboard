defmodule GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.CoachManagerTest do
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.Team
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.Coach
  alias GoChampsScoreboard.Sports.Basketball.Reports.FibaScoresheet.CoachManager

  use ExUnit.Case

  describe "find_coach/2" do
    test "returns the coach with the given ID from a given team when coach is the head coach" do
      coach = %Coach{
        id: "123",
        name: "Coach 1",
        fouls: []
      }

      team = %Team{
        coach: coach,
        assistant_coach: %Coach{
          id: "456",
          name: "Assistant Coach 1",
          fouls: []
        }
      }

      result = CoachManager.find_coach(team, "123")

      assert result == coach
    end

    test "returns the coach with the given ID from a given team when coach is an assistant coach" do
      coach = %Coach{
        id: "456",
        name: "Assistant Coach 1",
        fouls: []
      }

      team = %Team{
        coach: %Coach{
          id: "123",
          name: "Coach 1",
          fouls: []
        },
        assistant_coach: coach
      }

      result = CoachManager.find_coach(team, "456")

      assert result == coach
    end
  end
end
