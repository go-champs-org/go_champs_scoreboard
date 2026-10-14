defmodule GoChampsScoreboard.Telemetry do
  @moduledoc """
  Emits the telemetry events exported by `GoChampsScoreboard.PromEx.GamePlugin`.

  No game id is ever used as a tag (unbounded cardinality), and the
  one-per-second game tick is deliberately not measured.

  `span/2` emits `[:go_champs_scoreboard, name, :duration]` with
  `%{duration: native_time}` and `%{result: :ok | :error | :exception}`.
  """

  @spec span(atom(), (-> result)) :: result when result: term()
  def span(name, fun) when is_atom(name) and is_function(fun, 0) do
    start = System.monotonic_time()

    try do
      result = fun.()
      emit_duration(name, start, result_tag(result))
      result
    catch
      kind, reason ->
        stacktrace = __STACKTRACE__
        emit_duration(name, start, :exception)
        :erlang.raise(kind, reason, stacktrace)
    end
  end

  @spec game_event_processed(String.t()) :: :ok
  def game_event_processed(key) do
    :telemetry.execute([:go_champs_scoreboard, :game_event, :processed], %{count: 1}, %{key: key})
  end

  @spec rabbitmq_unroutable() :: :ok
  def rabbitmq_unroutable do
    :telemetry.execute([:go_champs_scoreboard, :rabbitmq, :unroutable], %{count: 1}, %{})
  end

  @doc "Polled by PromEx: emits how many games have a running ticker."
  @spec live_games() :: :ok
  def live_games do
    count = Registry.count(GoChampsScoreboard.Infrastructure.GameTickerRegistry)
    :telemetry.execute([:go_champs_scoreboard, :game, :live], %{count: count}, %{})
  end

  defp emit_duration(name, start, result) do
    :telemetry.execute(
      [:go_champs_scoreboard, name, :duration],
      %{duration: System.monotonic_time() - start},
      %{result: result}
    )
  end

  defp result_tag(:error), do: :error
  defp result_tag({:error, _}), do: :error
  defp result_tag(_), do: :ok
end
