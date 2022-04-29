defmodule Flow.Reporter.Composite do
  defstruct children: []

  alias Flow.Reporter.Composite

  def new(children) when is_list(children), do: %Composite{children: children}
  def new(child), do: new([child])
end

defimpl Flow.Telemetry.Collector, for: Flow.Reporter.Composite do
  alias Flow.Reporter.Composite
  alias Flow.Telemetry.Collector

  def handle_start(%Composite{children: children}, start_event) do
    Enum.each(children, &Collector.handle_start(&1, start_event))
  end

  def handle_stop(%Composite{children: children}, stop_event) do
    Enum.each(children, &Collector.handle_stop(&1, stop_event))
  end
end
