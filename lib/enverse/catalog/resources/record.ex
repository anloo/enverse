defmodule Enverse.Catalog.Record do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

    postgres do
      table "records"
      repo Enverse.Repo
    end

    code_interface do
      define_for Enverse.Catalog
      define :create, action: :create
      define :read_all, action: :read
      define :update, action: :update
      define :destroy, action: :destroy
      define :get_by_id, args: [:id], action: :by_id
    end

    actions do
      defaults [:create, :read, :update, :destroy]

      read :by_id do
        argument :id, :uuid, allow_nil?: false
        get? true
        filter expr(id == ^arg(:id))
      end

      create do
        accept([:variables, :metdata, :dataset_id])
      end
    end

    attributes do
      uuid_primary_key :id

      attribute :variables, :map do
        allow_nil? false
        default %{}
      end

      attribute :metdata, :map do
        allow_nil? false
        default %{}
      end
    end

    relationships do
      belongs_to :dataset, Enverse.Catalog.Dataset do
        attribute_writable? true
      end
    end
end
