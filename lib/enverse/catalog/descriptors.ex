defmodule Enverse.Catalog.Descriptors.Variable do
  use Ash.Resource,
    data_layer: :embedded

  code_interface do
    define_for Enverse.Catalog
    define :create, action: :create
  end

  attributes do
    attribute :data_type, :atom do
      allow_nil? false
      constraints [
        one_of: [
          :boolean,
          :datetime,
          :float,
          :integer,
          :string,
        ]
      ]
    end

    attribute :category, :atom do
      constraints [
        one_of: [
          :location,
          :time,
        ]
      ]
    end

    attribute :source_name, :string, allow_nil?: false
    attribute :target_name, :string, allow_nil?: false
    attribute :short_name, :string
    attribute :long_name, :string
    attribute :unit, :string

  end
end

defmodule Enverse.Catalog.Descriptors.Dataset do
  use Ash.Resource,
    data_layer: :embedded

  code_interface do
    define_for Enverse.Catalog
    define :create, action: :create
  end

  attributes do
    attribute :latitude_source, :string
    attribute :longitude_source, :string
    attribute :elevation_source, :string
    attribute :time_source, :string
    attribute :variables, {:array, Enverse.Catalog.Descriptors.Variable}
  end
end
