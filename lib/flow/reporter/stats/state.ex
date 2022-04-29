defmodule Flow.Reporter.Stats.State do
  require Protocol
  Protocol.derive(Jason.Encoder, Flow.Telemetry.Event.Span)

  alias Flow.Reporter.Stats.State, as: State
  alias Flow.Telemetry.Event.{Start, Stop, Span}

  defstruct [:pending, :store_path, :write_stream]

  def new(id) do
    file_name = id <> ".jsonl"
    path = cache_path(file_name)
    write_stream = File.stream!(path, [:append])

    %State{pending: %{}, store_path: path, write_stream: write_stream}
  end

  def track_start(state = %State{pending: pending}, start = %Start{ref: ref}) do
    pending = Map.put_new(pending, ref, start)
    %State{state | pending: pending}
  end

  def match_start_stop(state = %State{}, stop = %Stop{ref: ref}) do
    %State{pending: pending, write_stream: stream} = state
    {start, pending} = Map.pop!(pending, ref)

    encode = fn span ->
      Jason.encode!(span) <> "\n"
    end

    start
    |> Span.new(stop)
    |> encode.()
    |> List.wrap()
    |> Enum.into(stream)

    %State{state | pending: pending}
  end

  def spans_stream(%State{store_path: path}) do
    path
    |> File.stream!(read_ahead: 20_000)
    |> Stream.map(&Jason.decode!/1)
    |> Stream.map(&span_from_map!/1)
  end

  defp span_from_map!(map) do
    # Recreate Span structure from the provided map, used mostly after some
    # decode operation. If id was composed by atoms they won't get recovered and
    # no check is performed on the validity of the fields.
    raw =
      %Span{}
      |> Map.from_struct()
      |> Map.keys()
      |> Enum.map(&Atom.to_string/1)
      |> Enum.map(fn string_key ->
        {String.to_atom(string_key), Map.fetch!(map, string_key)}
      end)
      |> then(&struct(Span, &1))

    %Span{raw | resolution: String.to_atom(raw.resolution)}
  end

  defp cache_path(file_name) do
    Path.join([System.tmp_dir!(), file_name])
  end
end
