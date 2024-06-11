defmodule Enverse.Catalog.Dataset do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "datasets"
    repo Enverse.Repo
  end

  code_interface do
    define_for Enverse.Catalog
    define :create, args: [:files], action: :create
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, args: [:id], action: :by_id
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true
      argument :files, {:array, :struct} do
        allow_nil? false
      end
      change after_action &save_files/2
    end

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      get? true
      filter expr(id == ^arg(:id))
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

    attribute :descriptor, Enverse.Catalog.Descriptors.Dataset do
      allow_nil? false
    end
  end

  relationships do
    has_many :record, Enverse.Catalog.Record
  end


  defp save_files(changeset, result) do
    Enverse.Catalog.Storage.put(
      changeset |> Ash.Changeset.get_attribute(:id),
      changeset |> Ash.Changeset.get_argument(:files)
    )
    {:ok, result}
  end

end
