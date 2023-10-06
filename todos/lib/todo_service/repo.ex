defmodule TodoService.Repo do
  use Ecto.Repo,
    otp_app: :todo_service,
    adapter: Ecto.Adapters.Postgres
end
