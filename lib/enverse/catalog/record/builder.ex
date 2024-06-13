defmodule Enverse.Catalog.Record.Builder do
  defstruct [:descriptor]

  def new(%{} = descriptor),
    do: %__MODULE__{descriptor: descriptor}

  def build(%__MODULE__{} = builder, %{} = data) do
    variables =
      builder.descriptor.variables
      |> Enum.reduce(%{},
        fn descriptor, described_variables ->
          Map.put(
            described_variables,
            descriptor.target_name,
            Map.get(data, descriptor.source_name)
          )
        end
    )

    %{
      dataset_id: Map.get(data, "dataset_id"),
      latitude: Map.get(
        variables,
        builder.descriptor
        |> Map.get(:latitude_source, "latitude")
      ),
      longitude: Map.get(
        variables,
        builder.descriptor
        |> Map.get(:longitude_source, "longitude")
      ),
      elevation: Map.get(
        variables,
        builder.descriptor
        |> Map.get(:elevation_source, "elevation")
      ),
      time: Map.get(
        variables,
        builder.descriptor
        |> Map.get(:time_source, "time")
      ),
      variables: variables
    }
  end

end
