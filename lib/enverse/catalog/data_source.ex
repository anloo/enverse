defmodule Enverse.Catalog.DataSource do
  defstruct [:df]

  alias Explorer.DataFrame

  alias Enverse.Catalog.{FileInput, Ingestible}

  def new(%DataFrame{} = df),
    do: %__MODULE__{df: df}

  def new(%FileInput{} = file) when file.ext in [".csv"],
    do: new(file.path |> DataFrame.from_csv!())

  def new(%FileInput{} = file) when file.ext in [".tsv", ".txt"],
    do: new(file.path |> DataFrame.from_csv!(delimiter: "\t"))

  def new(input) when is_list(input),
    do: new(
      input
      |> Enum.map(fn i -> new(i).df end)
      |> DataFrame.concat_rows()
    )


  defimpl Ingestible do
    def to_schema(%{df: df}) do
      df.dtypes
      |> Enum.reduce(%{}, fn
        {name, {:s, _}}, schema -> Map.put(schema, name, :integer)
        {name, {:u, _}}, schema -> Map.put(schema, name, :integer)
        {name, {:f, _}}, schema -> Map.put(schema, name, :float)
        {name, :string}, schema -> Map.put(schema, name, :string)
      end)
    end

    def to_stream(%{df: df}) do
      df |> DataFrame.to_rows_stream()
    end
  end

  def to_schema(%__MODULE__{} = data_source),
    do: data_source |> Ingestible.to_schema()

  def to_stream(%__MODULE__{} = data_source),
    do: data_source |> Ingestible.to_stream()
end
