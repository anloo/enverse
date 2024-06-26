defmodule Enverse.Catalog.Record do
  use Ash.Resource,
    domain: Enverse.Catalog,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "records"
    repo Enverse.Repo
  end

  resource do
    require_primary_key? false
  end

  code_interface do
    define :filter, action: :by_filter
  end

  actions do
    defaults []

    read :by_filter do
      argument :dataset, :struct do
        allow_nil? false
        constraints instance_of: Enverse.Catalog.Dataset
      end
      argument :between, {:array, :datetime} do
        constraints [min_length: 1, max_length: 2]
      end
      argument :within, {:array, :float} do
        constraints [min_length: 4, max_length: 4]
      end
      argument :criteria, :map
      prepare Enverse.Catalog.Record.Preparations.Filters
    end
  end

  attributes do
    attribute :latitude, :float
    attribute :longitude, :float
    attribute :elevation, :float
    attribute :time, :datetime

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
      allow_nil? false
      attribute_writable? true
    end
  end
end
