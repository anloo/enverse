defmodule Enverse.Catalog.Dataset.Changes.SaveFiles do
  use Ash.Resource.Change

  def change(changeset, _, _) do
    changeset
    |> Ash.Changeset.after_action(&save_files/2)
  end

  defp save_files(changeset, result) do
    Enverse.Catalog.Storage.put(
      changeset |> Ash.Changeset.get_attribute(:id),
      changeset |> Ash.Changeset.get_argument(:files)
    )
    {:ok, result}
  end
end
