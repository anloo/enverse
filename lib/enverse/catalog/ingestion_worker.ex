defmodule Enverse.Catalog.IngestionWorker do
  use Oban.Worker, queue: :ingestions

  alias Enverse.Catalog.{Dataset, DataSource, Record}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    dataset = Dataset.get_by_id!(id)

    data_source = DataSource.new(
      dataset |> Dataset.stored_files!()
    )

    builder = Record.Builder.new(dataset.descriptor)

    record_stream =
      data_source
      |> DataSource.to_stream()
      |> Stream.map(
        fn record ->
          builder
          |> Record.Builder.build(record)
          |> Map.put(:dataset_id, dataset.id)
        end
      )

    copy_stream = Record.CopyStream.new()

    copy_stream |> Record.CopyStream.run(record_stream)

    :ok
  end

end
