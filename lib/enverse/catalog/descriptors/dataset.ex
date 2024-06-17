defmodule Enverse.Catalog.Descriptors.Dataset do
  use Ash.Resource,
    data_layer: :embedded

  alias Ash.Changeset
  alias Enverse.Catalog.Descriptors.Variable

  code_interface do
    domain Enverse.Catalog
    define :create, action: :create
  end

  actions do
    defaults [:read]

    create :create do
      primary? true
      accept [:variables]
      change before_action &autodiscover/2
    end
  end

  attributes do
    attribute :latitude_source, :string
    attribute :longitude_source, :string
    attribute :elevation_source, :string
    attribute :time_source, :string
    attribute :variables, {:array, Variable}, allow_nil?: false
  end

  defp autodiscover(changeset, _) do
    changeset
    |> Changeset.change_new_attribute(
      :latitude_source,
      detect_source(
        changeset.attributes,
        :location,
        [~r/lat(itude)?_dd/, ~r/lat(itude)?_deg/, "lat"]
      )
    )
    |> Changeset.change_new_attribute(
      :longitude_source,
      detect_source(
        changeset.attributes,
        :location,
        [~r/lon(gitude)?_dd/, ~r/lon(gitude)?_deg/, "lon"]
      )
    )
  end

  defp detect_source(%{variables: variables}, category, patterns) do
    patterns
    |> Enum.find_value(fn p ->
      variables
      |> Enum.filter(& &1.category == category)
      |> Enum.map(& &1.target_name)
      |> Enum.find_value(& &1 =~ p and &1)
    end)
  end

end
