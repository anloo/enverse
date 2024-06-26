defmodule Enverse.Repo.Migrations.AddRecords do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:records, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("uuid_generate_v4()"), primary_key: true
      add :variables, :map, null: false, default: %{}
      add :metdata, :map, null: false, default: %{}

      add :dataset_id,
          references(:datasets,
            column: :id,
            name: "records_dataset_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end
  end

  def down do
    drop constraint(:records, "records_dataset_id_fkey")

    drop table(:records)
  end
end
