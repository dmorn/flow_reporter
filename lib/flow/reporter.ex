defmodule Flow.Reporter do
  def analyse(flow, resolution \\ :millisecond) do
    t =
      :erlang.system_time()
      |> System.convert_time_unit(:native, resolution)
      |> Integer.to_string()
      |> String.to_atom()

    event_prefix = [:flow, :reporter, t]

    stats = Flow.Reporter.Stats.new()
    {:ok, _} = Flow.Telemetry.Dispatcher.attach(stats, event_prefix)

    flow
    |> Flow.Telemetry.instrument(event_prefix)
    |> Flow.run()

    Flow.Reporter.Stats.report(stats)
  end
end
