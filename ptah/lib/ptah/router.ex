defmodule Ptah.Router do
  use Commanded.Commands.Router

  dispatch Ptah.CreateActor, to: Ptah.Actor, identity: :id
end
