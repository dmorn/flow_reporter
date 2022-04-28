defmodule Flow.ReporterTest do
  use ExUnit.Case

  alias Flow.Reporter

  test "analise/1 does produce a report" do
    %Reporter.Stats.Report{} =
      ["roses are red", "violets are blue"]
      |> Flow.from_enumerable()
      |> Flow.flat_map(&String.split/1)
      # For a deterministic partitioning
      |> Flow.partition(stages: 1)
      |> Flow.reduce(fn -> %{} end, fn x, acc ->
        Map.update(acc, x, 1, fn old -> old + 1 end)
      end)
      |> Reporter.analyse()
  end
end
