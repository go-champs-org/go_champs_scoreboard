defmodule GoChampsScoreboard.Statistics.Statistics do
  alias GoChampsScoreboard.Statistics.Operations.{Decrement, Increment}

  def calc(current_value, Decrement),
    do: Decrement.calc(current_value)

  def calc(current_value, Increment),
    do: Increment.calc(current_value)
end
