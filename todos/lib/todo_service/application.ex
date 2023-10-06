defmodule TodoService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TodoServiceWeb.Telemetry,
      # Start the Ecto repository
      TodoService.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: TodoService.PubSub},
      # Start the Endpoint (http/https)
      TodoServiceWeb.Endpoint
      # Start a worker by calling: TodoService.Worker.start_link(arg)
      # {TodoService.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TodoService.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TodoServiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
