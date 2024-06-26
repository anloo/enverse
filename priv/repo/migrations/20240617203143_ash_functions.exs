defmodule Enverse.Repo.Migrations.AshFunctions do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:datasets) do
      modify :updated_at, :utc_datetime_usec, default: fragment("(now() AT TIME ZONE 'utc')")
      modify :created_at, :utc_datetime_usec, default: fragment("(now() AT TIME ZONE 'utc')")
      modify :id, :uuid, default: fragment("gen_random_uuid()")
    end
  end

  def down do
    alter table(:datasets) do
      modify :id, :uuid, default: fragment("uuid_generate_v4()")
      modify :created_at, :utc_datetime_usec, default: fragment("now()")
      modify :updated_at, :utc_datetime_usec, default: fragment("now()")
    end
  end
end
