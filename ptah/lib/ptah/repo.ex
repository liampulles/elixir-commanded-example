defmodule Ptah.Repo do
  use Ecto.Repo,
    otp_app: :ptah,
    adapter: Ecto.Adapters.Postgres
end
