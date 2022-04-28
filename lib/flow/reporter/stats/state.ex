defmodule Flow.Reporter.Stats.State do
  alias Flow.Reporter.Stats.State, as: State
  alias Flow.Telemetry.Event.{Start, Stop, Span}

  defstruct pending: %{}, spans: []

  def new() do
    %__MODULE__{}
  end

  def track_start(state = %State{pending: pending}, start = %Start{ref: ref}) do
    pending = Map.put_new(pending, ref, start)
    %State{state | pending: pending}
  end

  def match_start_stop(state = %State{}, stop = %Stop{ref: ref}) do
    %State{pending: pending, spans: spans} = state

    {start, pending} = Map.pop!(pending, ref)
    span = Span.new(start, stop)

    %State{state | pending: pending, spans: [span | spans]}
  end
end
