defmodule Flow.Reporter.Stats.Report do
  # TODO: Implement IO.inspect protocol?

  alias Flow.Reporter.Stats.{State, Report}
  alias Flow.Telemetry.Event.Span

  @type t :: %__MODULE__{stats: Keyword.t()}
  defstruct stats: []

  def from_state(%State{spans: spans}) do
    new(spans)
  end

  @spec new([Span.t()], Span.time_unit()) :: Report.t()
  def new(spans, resolution \\ :millisecond) do
    stats =
      spans
      |> Enum.map(&Span.convert_time_unit(&1, resolution))
      |> Enum.group_by(fn %Span{id: id} -> id end)
      |> Enum.map(fn {k, spans} ->
        stats =
          spans
          |> Enum.map(fn %Span{duration: duration} -> duration end)
          |> Statistex.statistics(percentiles: [25, 50, 75])

        {k, stats}
      end)

    # TODO: sort by depth?

    %Report{stats: stats}
  end
end
