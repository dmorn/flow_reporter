defmodule Flow.Reporter.Plot do
  @moduledoc """
  VegaLite reporter!
  """

  alias VegaLite, as: Vl
  alias Flow.Telemetry.Event.Span

  @doc """
  Encodes a list of spans into the provided VegaLite specification as data
  source. Processed items get the y axis with a logarithmic scale, time on x,
  the color dimension is provided by the span identifier. Time is relative to
  the first span in the list.
  """
  @spec encode_spans(VegaLite.t(), [Span.t()]) :: VegaLite.t()
  def encode_spans(vl, spans) when is_list(spans) do
    t0 =
      spans
      |> Enum.map(fn %Span{start_at: start_at} -> start_at end)
      |> Enum.min()

    spans
    |> Enum.map(fn %Span{end_at: end_at, result_count: count, id: id} ->
      %{"time" => end_at - t0, "count" => count, "operation" => id}
    end)
    |> then(&encode_measurements(vl, &1))
  end

  defp encode_measurements(vl, measurements) do
    vl
    |> Vl.data_from_values(measurements)
    |> Vl.encode_field(:x, "time", type: :temporal)
    |> Vl.encode_field(:y, "count", type: :quantitative, scale: [type: :log])
    |> Vl.encode_field(:color, "operation", type: :quantitative)
  end
end
