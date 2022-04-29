defmodule Flow.Reporter.Plot do
  @moduledoc """
  VegaLite reporter!
  """

  alias VegaLite, as: Vl
  alias Flow.Telemetry.Event.Span

  @doc """
  Encodes a list of spans into the provided VegaLite specification as data
  source. Processed items count get the y axis, time on x, the color dimension
  is provided by the span identifier. Time is relative to the first span in the
  list.
  """
  @spec encode_spans(VegaLite.t(), Enumerable.t()) :: VegaLite.t()
  def encode_spans(vl, spans) do
    spans =
      spans
      |> Enum.map(&Span.convert_time_unit(&1, :millisecond))
      |> Enum.sort(fn %Span{end_at: lhs}, %Span{end_at: rhs} -> lhs < rhs end)

    t0 =
      spans
      |> List.first()
      |> Map.get(:start_at)

    spans
    |> Enum.map_reduce(%{}, fn %Span{end_at: end_at, result_count: count, id: id}, acc ->
      # NOTE: count here represents the new count. Each line will start from
      # the first computed batch instead of 0. We might want to add some
      # artificial initial measurements at t0.
      {count, acc} =
        Map.get_and_update(acc, id, fn old ->
          old = if old == nil, do: 0, else: old
          new = old + count
          {new, new}
        end)

      {%{"time" => end_at - t0, "count" => count, "operation" => id}, acc}
    end)
    |> elem(0)
    |> then(&encode_measurements(vl, &1))
  end

  defp encode_measurements(vl, measurements) do
    vl
    |> Vl.data_from_values(measurements)
    |> Vl.encode_field(:x, "time", type: :temporal, time_unit: :milliseconds)
    |> Vl.encode_field(:y, "count", type: :quantitative)
    |> Vl.encode_field(:color, "operation", type: :nominal)
  end
end
