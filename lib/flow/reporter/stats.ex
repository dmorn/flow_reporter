defmodule Flow.Reporter.Stats do
  defstruct [:pid]

  alias Flow.Reporter.Stats, as: Stats
  alias Flow.Reporter.Stats.State, as: State
  alias Flow.Reporter.Stats.Report, as: Report

  def new() do
    {:ok, pid} = Agent.start_link(fn -> State.new() end)
    %__MODULE__{pid: pid}
  end

  def track_start(%Stats{pid: pid}, start) do
    Agent.cast(pid, fn state -> State.track_start(state, start) end)
  end

  def match_start_stop(%Stats{pid: pid}, stop) do
    Agent.cast(pid, fn state -> State.match_start_stop(state, stop) end)
  end

  def report(%Stats{pid: pid}) do
    state = Agent.get(pid, fn state -> state end, :infinity)
    Report.from_state(state)
  end

  def spans(%Stats{pid: pid}) do
    pid
    |> Agent.get(fn state -> state end, :infinity)
    |> Stats.State.spans()
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
