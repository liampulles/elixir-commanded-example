
# --- Commands ---

defmodule Ptah.CommandModel.CreateActor do
  defstruct [:id, :name, :date_of_birth]
end

defmodule Ptah.CommandModel.DeleteActor do
  defstruct [:id]
end

# --- Events ---

defmodule Ptah.CommandModel.ActorCreated do
  @derive Jason.Encoder
  defstruct [:id, :name, :date_of_birth]
end

defmodule Ptah.CommandModel.ActorDeleted do
  @derive Jason.Encoder
  defstruct [:id]
end

# Router
defmodule Ptah.CommandModel.ActorRouter do
  use Commanded.Commands.Router

  # Actor
  dispatch Ptah.CommandModel.CreateActor, to: Ptah.CommandModel.Actor, identity: :id
  dispatch Ptah.CommandModel.DeleteActor, to: Ptah.CommandModel.Actor, identity: :id
end

# Aggregate
defmodule Ptah.CommandModel.Actor do
  defstruct [
    :id,
    :name,
    :date_of_birth
  ]

  # --- Command handlers ---

  # Create actor
  # -> ID, name and date of birth are required
  def execute(%Ptah.CommandModel.Actor{}, %Ptah.CommandModel.CreateActor{id: nil}) do
    {:error, :id_is_required}
  end
  def execute(%Ptah.CommandModel.Actor{}, %Ptah.CommandModel.CreateActor{name: ""}) do
    {:error, :name_is_required}
  end
  def execute(%Ptah.CommandModel.Actor{}, %Ptah.CommandModel.CreateActor{name: nil}) do
    {:error, :name_is_required}
  end
  def execute(%Ptah.CommandModel.Actor{}, %Ptah.CommandModel.CreateActor{date_of_birth: nil}) do
    {:error, :date_of_birth_is_required}
  end
  # -> When actor does not exist yet, go ahead
  def execute(%Ptah.CommandModel.Actor{id: nil}, %Ptah.CommandModel.CreateActor{id: id, name: name, date_of_birth: date_of_birth}) do
    %Ptah.CommandModel.ActorCreated{id: id, name: name, date_of_birth: date_of_birth}
  end
  # -> Else, when actor already exists, fail
  def execute(%Ptah.CommandModel.Actor{}, %Ptah.CommandModel.CreateActor{}) do
    {:error, :actor_already_exists}
  end

  # Delete actor
  # -> ID is required
  def execute(%Ptah.CommandModel.Actor{}, %Ptah.CommandModel.DeleteActor{id: nil}) do
    {:error, :id_is_required}
  end
  # TODO: Don't send event if already deleted or not existing, but also don't fail?
  def execute(%Ptah.CommandModel.Actor{}, %Ptah.CommandModel.DeleteActor{id: id}) do
    %Ptah.CommandModel.ActorDeleted{id: id}
  end

  # --- State mutators ---

  # Create actor
  def apply(%Ptah.CommandModel.Actor{} = actor, %Ptah.CommandModel.ActorCreated{id: id, name: name, date_of_birth: date_of_birth}) do
    %Ptah.CommandModel.Actor{actor |
      id: id,
      name: name,
      date_of_birth: date_of_birth
    }
  end

  # Delete actor
  def apply(%Ptah.CommandModel.Actor{}, %Ptah.CommandModel.ActorDeleted{}) do
    nil
  end
end
