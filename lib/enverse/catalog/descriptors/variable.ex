defmodule Enverse.Catalog.Descriptors.Variable do
  @derive Jason.Encoder
  @enforce_keys [:data_type, :source_name, :target_name]
  defstruct [:data_type, :source_name, :target_name, :short_name, :long_name, :unit, :category]
end
