defmodule Flow.Reporter.PlotTest do
  use ExUnit.Case

  alias VegaLite, as: Vl
  alias Flow.Reporter
  alias Flow.Reporter.Plot
  alias Flow.Reporter.Stats

  test "from_spans/1 produces a VegaLite spec" do
    flow =
      ["roses are red", "violets are blue"]
      |> Flow.from_enumerable()
      |> Flow.flat_map(&String.split/1)
      # For a deterministic partitioning
      |> Flow.partition(stages: 1)
      |> Flow.reduce(fn -> %{} end, fn x, acc ->
        Map.update(acc, x, 1, fn old -> old + 1 end)
      end)

    collector = Stats.new()

    flow
    |> Reporter.attach(collector)
    |> Flow.run()

    %Vl{} =
      collector
      |> Stats.spans()
      |> then(&Plot.encode_spans(Vl.new(), &1))
  end
end
