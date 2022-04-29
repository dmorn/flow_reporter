defmodule Flow.ReporterTest do
  use ExUnit.Case

  alias Flow.Reporter
  alias Flow.Reporter.{Composite, Stats}

  test "attach/1 does not break" do
    flow =
      ["roses are red", "violets are blue"]
      |> Flow.from_enumerable()
      |> Flow.flat_map(&String.split/1)
      # For a deterministic partitioning
      |> Flow.partition(stages: 1)
      |> Flow.reduce(fn -> %{} end, fn x, acc ->
        Map.update(acc, x, 1, fn old -> old + 1 end)
      end)

    id = Reporter.uniq_event_prefix()
    stats = Stats.new(id)
    collector = Composite.new([stats])

    flow
    |> Reporter.attach(collector, id)
    |> Flow.run()

    %Stats.Report{} = Stats.report(stats)
  end
end
