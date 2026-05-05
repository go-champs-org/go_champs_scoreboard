defmodule GoChampsScoreboardWeb.ScoreboardReportViewersControllerTest do
  use GoChampsScoreboardWeb.ConnCase

  describe "show" do
    test "renders report viewer page with valid report_slug", %{conn: conn} do
      game_id = Ecto.UUID.generate()

      conn =
        conn
        |> init_test_session(%{"api_token" => "test-token-123"})
        |> get(~p"/scoreboard/report_viewer/#{game_id}?report_slug=simple-example")

      assert html_response(conn, 200) =~ "data-live-react-class=\"Components.ReportViewer\""
      assert html_response(conn, 200) =~ "report-viewer-receiver"
      assert html_response(conn, 200) =~ "report-viewer-container"
    end

    test "renders report viewer page with simple-example slug", %{conn: conn} do
      game_id = Ecto.UUID.generate()

      conn =
        conn
        |> init_test_session(%{"api_token" => "test-token-123"})
        |> get(~p"/scoreboard/report_viewer/#{game_id}?report_slug=simple-example")

      assert html_response(conn, 200) =~ "data-live-react-class=\"Components.ReportViewer\""
    end

    test "returns 400 when report_slug is missing", %{conn: conn} do
      game_id = Ecto.UUID.generate()

      conn =
        conn
        |> init_test_session(%{"api_token" => "test-token-123"})
        |> get(~p"/scoreboard/report_viewer/#{game_id}")

      assert json_response(conn, 400) == %{"error" => "Missing required parameter: report_slug"}
    end

    test "handles unsupported report_slug gracefully", %{conn: conn} do
      game_id = Ecto.UUID.generate()

      conn =
        conn
        |> init_test_session(%{"api_token" => "test-token-123"})
        |> get(~p"/scoreboard/report_viewer/#{game_id}?report_slug=invalid-report-type")

      # Should still render the page (with empty data), not crash with 500
      assert html_response(conn, 200) =~ "data-live-react-class=\"Components.ReportViewer\""
    end

    test "works without session api_token", %{conn: conn} do
      game_id = Ecto.UUID.generate()

      conn = get(conn, ~p"/scoreboard/report_viewer/#{game_id}?report_slug=simple-example")

      # Should still render even without api_token
      assert html_response(conn, 200) =~ "data-live-react-class=\"Components.ReportViewer\""
    end

    test "passes report_slug to template", %{conn: conn} do
      game_id = Ecto.UUID.generate()

      conn =
        conn
        |> init_test_session(%{"api_token" => "test-token-123"})
        |> get(~p"/scoreboard/report_viewer/#{game_id}?report_slug=simple-example")

      response = html_response(conn, 200)
      assert response =~ "simple-example"
    end

    test "catches FunctionClauseError from unsupported report slugs", %{conn: conn} do
      game_id = Ecto.UUID.generate()

      conn =
        conn
        |> init_test_session(%{"api_token" => "test-token-123"})
        |> get(~p"/scoreboard/report_viewer/#{game_id}?report_slug=completely-unknown")

      # Should catch the FunctionClauseError and return 200 with empty data
      # instead of 500
      assert html_response(conn, 200)
    end
  end
end
