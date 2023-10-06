
# --- Commands ---

defmodule Ptah.CommandModel.CreateActor do
  defstruct [:id, :name, :date_of_birth]
end
alias Ptah.CommandModel.CreateActor

defmodule Ptah.CommandModel.DeleteActor do
  defstruct [:id]
end
alias Ptah.CommandModel.DeleteActor

# --- Events ---

defmodule Ptah.CommandModel.ActorCreated do
  @derive Jason.Encoder
  defstruct [:id, :name, :date_of_birth]
end
alias Ptah.CommandModel.ActorCreated

defmodule Ptah.CommandModel.ActorDeleted do
  @derive Jason.Encoder
  defstruct [:id]
end
alias Ptah.CommandModel.ActorDeleted

# Aggregate
defmodule Ptah.CommandModel.Actor do
  alias Ptah.CommandModel.Actor
  defstruct [
    :id,
    :name,
    :date_of_birth
  ]

  # --- Command handlers ---

  # Create actor
  # -> ID, name and date of birth are required
  def execute(%Actor{}, %CreateActor{id: nil}) do
    {:error, :id_is_required}
  end
  def execute(%Actor{}, %CreateActor{name: ""}) do
    {:error, :name_is_required}
  end
  def execute(%Actor{}, %CreateActor{name: nil}) do
    {:error, :name_is_required}
  end
  def execute(%Actor{}, %CreateActor{date_of_birth: nil}) do
    {:error, :date_of_birth_is_required}
  end
  # -> When actor does not exist yet, go ahead
  def execute(%Actor{id: nil}, %CreateActor{id: id, name: name, date_of_birth: date_of_birth}) do
    %ActorCreated{id: id, name: name, date_of_birth: date_of_birth}
  end
  # -> Else, when actor already exists, fail
  def execute(%Actor{}, %CreateActor{}) do
    {:error, :actor_already_exists}
  end

  # Delete actor
  # -> ID is required
  def execute(%Actor{}, %DeleteActor{id: nil}) do
    {:error, :id_is_required}
  end
  # TODO: Don't send event if already deleted or not existing, but also don't fail?
  def execute(%Actor{}, %DeleteActor{id: id}) do
    %ActorDeleted{id: id}
  end

  # --- State mutators ---

  # Create actor
  def apply(%Actor{} = actor, %ActorCreated{id: id, name: name, date_of_birth: date_of_birth}) do
    %Actor{actor |
      id: id,
      name: name,
      date_of_birth: date_of_birth
    }
  end

  # Delete actor
  def apply(%Actor{}, %ActorDeleted{}) do
    nil
  end
end

# Router
defmodule Ptah.CommandModel.ActorRouter do
  use Commanded.Commands.Router

  # Actor
  dispatch CreateActor, to: Ptah.CommandModel.Actor, identity: :id
  dispatch DeleteActor, to: Ptah.CommandModel.Actor, identity: :id
end
