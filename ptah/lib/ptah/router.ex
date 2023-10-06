defmodule Ptah.Router do
  use Commanded.Commands.Router

  # Actor
  dispatch Ptah.CreateActor, to: Ptah.Actor, identity: :id
  dispatch Ptah.DeleteActor, to: Ptah.Actor, identity: :id
end
