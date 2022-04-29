defmodule Flow.Reporter do
  @doc """
  This function returns an instrumented flow that will send telemetry events to
  the provided collector at each execution.
  """
  @spec attach(Flow.t(), Flow.Telemetry.Collector.t(), list() | String.t()) :: Flow.t()
  def attach(flow, collector, event_prefix) do
    {:ok, _} = Flow.Telemetry.Dispatcher.attach(collector, event_prefix)
    Flow.Telemetry.instrument(flow, event_prefix)
  end

  def attach(flow, collector) do
    attach(flow, collector, uniq_event_prefix())
  end

  def uniq_event_prefix() do
    :erlang.system_time()
    |> Integer.to_string()
    |> String.to_atom()
    |> List.wrap()
    |> Enum.concat([:reporter, :flow])
    |> Enum.reverse()
  end
end
