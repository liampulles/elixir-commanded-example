defmodule Ptah.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  use Commanded.Application,
    otp_app: :ptah,
    event_store: [
      adapter: Commanded.EventStore.Adapters.EventStore,
      event_store: Ptah.EventStore
    ]

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PtahWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Ptah.PubSub},
      # Start the Endpoint (http/https)
      PtahWeb.Endpoint
      # Start a worker by calling: Ptah.Worker.start_link(arg)
      # {Ptah.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ptah.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PtahWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
