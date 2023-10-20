# Define the commanded event store
defmodule Ptah.EventStore do
  use EventStore, otp_app: :ptah
end

# Define the commanded supervisor
defmodule Ptah.Commanded do
  use Commanded.Application,
  otp_app: :ptah,
  event_store: [
    adapter: Commanded.EventStore.Adapters.EventStore,
    event_store: Ptah.EventStore
  ]

  # Routers, i.e. where to direct commands
  router Ptah.CommandModel.ActorRouter
  router Ptah.CommandModel.MediaRouter
end

defmodule Ptah.Application do
  @impl true
  def start(_type, _args) do
    children = [
      # Commanded
      Ptah.Commanded,

      # Phoenix
      PtahWeb.Telemetry,

      # Start the Ecto repository
      Ptah.Repo,

      # Start the PubSub system
      {Phoenix.PubSub, name: Ptah.PubSub},
      PtahWeb.Endpoint
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
