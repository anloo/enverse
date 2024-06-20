defmodule Enverse.Catalog.Dataset.Actions.ListFiles do
  use Ash.Resource.Actions.Implementation

  def run(input, _, _) do
    files = Enverse.Catalog.Storage.list(
      input.arguments.dataset.id
    )
    {:ok, files}
  end
end
