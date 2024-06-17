defmodule Enverse.Catalog.Dataset do
  alias Enverse.Catalog.Descriptors

  use Ash.Resource,
    domain: Enverse.Catalog,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "datasets"
    repo Enverse.Repo
  end

  code_interface do
    define :create, args: [:files], action: :create
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, args: [:id], action: :by_id
    define :stored_files, args: [:dataset]
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true
      accept [:title, :description]
      argument :files, {:array, :struct} do
        allow_nil? false
      end
      change before_action &autodescribe/2
      change after_action &save_files/3
    end

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      get? true
      filter expr(id == ^arg(:id))
    end

    action :stored_files, {:array, :struct} do
      argument :dataset, :struct do
        allow_nil? false
      end
      run &list_files/2
    end
  end

  attributes do
    uuid_primary_key :id
    create_timestamp :created_at
    update_timestamp :updated_at

    attribute :title, :string do
      allow_nil? false
    end

    attribute :description, :string do
      allow_nil? false
    end

    attribute :metdata, :map do
      allow_nil? false
      default %{}
    end

    attribute :descriptor, Descriptors.Dataset do
      allow_nil? false
    end
  end

  relationships do
    has_many :record, Enverse.Catalog.Record
  end


  defp autodescribe(changeset, _) do
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

  defp save_files(changeset, result, _) do
    Enverse.Catalog.Storage.put(
      changeset |> Ash.Changeset.get_attribute(:id),
      changeset |> Ash.Changeset.get_argument(:files)
    )
    {:ok, result}
  end

  defp list_files(input, _context) do
    files = Enverse.Catalog.Storage.list(
      input.arguments.dataset.id
    )
    {:ok, files}
  end
end
