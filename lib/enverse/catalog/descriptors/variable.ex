defmodule Enverse.Catalog.Descriptors.Variable do
  use Ash.Resource,
    data_layer: :embedded

  alias Ash.Changeset

  code_interface do
    domain Enverse.Catalog
    define :create, action: :create
  end

  actions do
    defaults []

    create :create do
      primary? true
      accept [:source_name, :data_type]
      change before_action &autodiscover/2
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


  defp autodiscover(changeset, _) do
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
