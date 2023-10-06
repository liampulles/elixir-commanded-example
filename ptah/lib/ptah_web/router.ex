defmodule PtahWeb.Router do
  use PtahWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", PtahWeb do
    pipe_through :api
  end
end
