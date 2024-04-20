defmodule Enverse.Catalog.Descriptors.Dataset do
  @derive Jason.Encoder
  @enforce_keys [:variables]
  defstruct [:latitude_source, :longitude_source, :elevation_source, :time_source, :variables]
end
