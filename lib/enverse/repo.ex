defmodule Enverse.Repo do
  use AshPostgres.Repo, otp_app: :enverse

  def installed_extensions do
    ["uuid-ossp", "citext", "postgis"]
  end
end
