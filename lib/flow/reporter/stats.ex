defmodule Flow.Reporter.Stats do
  defstruct [:pid]

  alias Flow.Reporter.Stats, as: Stats
  alias Flow.Reporter.Stats.State, as: State
  alias Flow.Reporter.Stats.Report, as: Report

  def new(id_or_list) when is_list(id_or_list) do
    id_or_list
    |> Enum.join("-")
    |> new()
  end

  def new(id_or_list) when is_binary(id_or_list) do
    {:ok, pid} = Agent.start_link(fn -> State.new(id_or_list) end)
    %__MODULE__{pid: pid}
  end

  def track_start(%Stats{pid: pid}, start) do
    Agent.cast(pid, fn state -> State.track_start(state, start) end)
  end

  def match_start_stop(%Stats{pid: pid}, stop) do
    Agent.cast(pid, fn state -> State.match_start_stop(state, stop) end)
  end

  def report(stats = %Stats{}) do
    stats
    |> spans_stream()
    |> Report.from_spans()
  end

  def spans_stream(%Stats{pid: pid}) do
    Agent.get(pid, fn state -> State.spans_stream(state) end)
  end
end

defimpl Flow.Telemetry.Collector, for: Flow.Reporter.Stats do
  alias Flow.Reporter.Stats

  def handle_start(stats, start) do
    Stats.track_start(stats, start)
  end

  def handle_stop(stats, stop) do
    Stats.match_start_stop(stats, stop)
  end
end
