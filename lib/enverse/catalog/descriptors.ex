defmodule Enverse.Catalog.Descriptors.Variable do
  use Ash.Resource,
    data_layer: :embedded

  alias Ash.Changeset

  code_interface do
    define_for Enverse.Catalog
    define :create, action: :create
  end

  actions do
    create :create do
      primary? true
      allow_nil_input [:target_name]
      change before_action &autodiscover/1
    end
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
          :unkown,
        ]
      ]
    end

    attribute :source_name, :string do
      allow_nil? false
      primary_key? true
    end

    attribute :target_name, :string, allow_nil?: false
    attribute :short_name, :string
    attribute :long_name, :string
    attribute :unit, :string
  end


  defp autodiscover(changeset) do
    changeset
    |> Changeset.change_new_attribute(
      :target_name,
      detect_target(changeset.attributes)
    )
    |> Changeset.change_new_attribute(
      :category,
      detect_category(changeset.attributes)
    )
  end

  defp detect_target(%{source_name: source_name}) do
    source_name
    |> String.downcase
    |> String.replace(~r/[^a-z0-9_]/, "_")
  end

  defp detect_category(attrs = %{data_type: :float}) do
    source_name = String.downcase(attrs.source_name)
    cond do
      source_name =~ "lat" -> :location
      source_name =~ "lon" -> :location
      source_name =~ "dep" -> :location
      source_name =~ "alt" -> :location
      true -> :unkown
    end
  end

  defp detect_category(%{data_type: :datetime}), do: :time

  defp detect_category(_), do: :unkown
end

defmodule Enverse.Catalog.Descriptors.Dataset do
  use Ash.Resource,
    data_layer: :embedded

  alias Ash.Changeset
  alias Enverse.Catalog.Descriptors.Variable

  code_interface do
    define_for Enverse.Catalog
    define :create, action: :create
  end

  actions do
    create :create do
      primary? true
      change before_action &autodiscover/1
    end
  end

  attributes do
    attribute :latitude_source, :string
    attribute :longitude_source, :string
    attribute :elevation_source, :string
    attribute :time_source, :string
    attribute :variables, {:array, Variable}, allow_nil?: false
  end

  defp autodiscover(changeset) do
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
