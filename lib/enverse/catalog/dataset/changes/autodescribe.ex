defmodule Enverse.Catalog.Dataset.Changes.Autodescribe do
  use Ash.Resource.Change

  alias Enverse.Catalog.Descriptors

  def change(changeset, _, _) do
    changeset
    |> Ash.Changeset.before_action(&autodescribe/1)
  end

  defp autodescribe(changeset) do
    [sample_file | _] =
      changeset |> Ash.Changeset.get_argument(:files)

    schema =
      sample_file
      |> Enverse.Catalog.DataSource.new
      |> Enverse.Catalog.DataSource.to_schema

    variables = schema |> Enum.map(
      fn {source_name, data_type} ->
        Descriptors.Variable.create!(%{
          source_name: source_name,
          data_type: data_type
        })
      end
    )

    changeset |> Ash.Changeset.change_attribute(
      :descriptor,
      Descriptors.Dataset.create!(%{variables: variables})
    )
  end

end
