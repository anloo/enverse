defmodule Enverse.Catalog.Record.CopyStream do
  def new() do
    Ecto.Adapters.SQL.stream(
      Enverse.Repo,
      """
      COPY records(
        latitude,
        longitude,
        elevation,
        time,
        variables,
        dataset_id
      )
      FROM STDIN
      DELIMITER '\t'
      NULL 'null'
      """
    )
  end

  def run(copy_stream, record_stream) do
    Enverse.Repo.transaction(
      fn ->
        record_stream
        |> Stream.map(&make_row/1)
        |> Stream.chunk_every(2000)
        |> Stream.into(copy_stream)
        |> Stream.run()
      end,
      timeout: :infinity
    )
  end

  defp make_row(record) do
    Enum.join([
      record.latitude || "null",
      record.longitude || "null",
      record.elevation || "null",
      record.time || "null",
      record.variables |> Jason.encode!(),
      record.dataset_id
    ], "\t") <> "\n"
  end
end
