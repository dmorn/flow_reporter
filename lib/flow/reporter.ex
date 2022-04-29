defmodule Flow.Reporter do
  # stats = Flow.Reporter.Stats.new()
  # analise(flow, stats)
  # Flow.Reporter.Stats.report(stats)

  @doc """
  This function returns an instrumented flow that will send telemetry events to
  the provided collector at each execution.
  """
  @spec attach(Flow.t(), Flow.Telemetry.Collector.t()) :: Flow.t()
  def attach(flow, collector) do
    event_prefix = uniq_event_prefix()
    {:ok, _} = Flow.Telemetry.Dispatcher.attach(collector, event_prefix)
    Flow.Telemetry.instrument(flow, event_prefix)
  end

  defp uniq_event_prefix() do
    :erlang.system_time()
    |> Integer.to_string()
    |> String.to_atom()
    |> List.wrap()
    |> Enum.concat([:reporter, :flow])
    |> Enum.reverse()
  end
end
