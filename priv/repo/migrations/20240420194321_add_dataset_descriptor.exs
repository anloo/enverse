defmodule Enverse.Repo.Migrations.AddDatasetDescriptor do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:datasets) do
      add :descriptor, :map, null: false
    end
  end

  def down do
    alter table(:datasets) do
      remove :descriptor
    end
  end
end