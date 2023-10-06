defmodule TodoServiceWeb.Router do
  use TodoServiceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TodoServiceWeb do
    pipe_through :api
  end
end
