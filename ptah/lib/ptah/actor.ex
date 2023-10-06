
# --- Commands ---

defmodule Ptah.CreateActor do
  defstruct [:id, :name, :date_of_birth]
end

defmodule Ptah.DeleteActor do
  defstruct [:id]
end

# --- Events ---

defmodule Ptah.ActorCreated do
  @derive Jason.Encoder
  defstruct [:id, :name, :date_of_birth]
end

defmodule Ptah.ActorDeleted do
  @derive Jason.Encoder
  defstruct [:id]
end

# Aggregate
defmodule Ptah.Actor do
  defstruct [
    :id,
    :name,
    :date_of_birth
  ]

  # --- Command handlers ---

  # Create actor
  # -> ID, name and date of birth are required
  def execute(%Ptah.Actor{}, %Ptah.CreateActor{id: nil}) do
    {:error, :id_is_required}
  end
  def execute(%Ptah.Actor{}, %Ptah.CreateActor{name: ""}) do
    {:error, :name_is_required}
  end
  def execute(%Ptah.Actor{}, %Ptah.CreateActor{name: nil}) do
    {:error, :name_is_required}
  end
  def execute(%Ptah.Actor{}, %Ptah.CreateActor{date_of_birth: nil}) do
    {:error, :date_of_birth_is_required}
  end
  # -> When actor does not exist yet, go ahead
  def execute(%Ptah.Actor{id: nil}, %Ptah.CreateActor{id: id, name: name, date_of_birth: date_of_birth}) do
    %Ptah.ActorCreated{id: id, name: name, date_of_birth: date_of_birth}
  end
  # -> Else, when actor already exists, fail
  def execute(%Ptah.Actor{}, %Ptah.CreateActor{}) do
    {:error, :actor_already_exists}
  end

  # Delete actor
  # -> ID is required
  def execute(%Ptah.Actor{}, %Ptah.DeleteActor{id: nil}) do
    {:error, :id_is_required}
  end
  # TODO: Don't send event if already deleted or not existing, but also don't fail?
  def execute(%Ptah.Actor{}, %Ptah.DeleteActor{id: id}) do
    %Ptah.ActorDeleted{id: id}
  end

  # --- State mutators ---

  # Create actor
  def apply(%Ptah.Actor{} = actor, %Ptah.ActorCreated{id: id, name: name, date_of_birth: date_of_birth}) do
    %Ptah.Actor{actor |
      id: id,
      name: name,
      date_of_birth: date_of_birth
    }
  end

  # Delete actor
  def apply(%Ptah.Actor{}, %Ptah.ActorDeleted{}) do
    nil
  end
end
