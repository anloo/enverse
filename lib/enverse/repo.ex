defmodule Enverse.Repo do
  use Ecto.Repo,
    otp_app: :enverse,
    adapter: Ecto.Adapters.Postgres
end
