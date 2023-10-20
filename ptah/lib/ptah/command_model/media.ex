
# --- Commands ---

defmodule Ptah.CommandModel.CreateMedia do
  defstruct [:id, :name, :release_date]
end
alias Ptah.CommandModel.CreateMedia

defmodule Ptah.CommandModel.DeleteMedia do
  defstruct [:id]
end
alias Ptah.CommandModel.DeleteMedia

defmodule Ptah.CommandModel.AddCast do
  defstruct [:id, :actor_id]
end
alias Ptah.CommandModel.AddCast

# --- Events ---

defmodule Ptah.CommandModel.MediaCreated do
  @derive Jason.Encoder
  defstruct [:id, :name, :release_date]
end
alias Ptah.CommandModel.MediaCreated

defmodule Ptah.CommandModel.MediaDeleted do
  @derive Jason.Encoder
  defstruct [:id]
end
alias Ptah.CommandModel.MediaDeleted

defmodule Ptah.CommandModel.CastAdded do
  @derive Jason.Encoder
  defstruct [:id, :actor_id]
end
alias Ptah.CommandModel.CastAdded

# Aggregate
defmodule Ptah.CommandModel.Media do
  defstruct [
    :id,
    :name,
    :release_date,
    :cast_actor_ids
  ]
  alias __MODULE__

  # --- Command handlers ---

  # Create media
  # -> ID, name and release date are required
  def execute(%Media{}, %CreateMedia{id: nil}) do
    {:error, :id_is_required}
  end
  def execute(%Media{}, %CreateMedia{name: ""}) do
    {:error, :name_is_required}
  end
  def execute(%Media{}, %CreateMedia{name: nil}) do
    {:error, :name_is_required}
  end
  def execute(%Media{}, %CreateMedia{release_date: nil}) do
    {:error, :release_date_is_required}
  end
  # -> When media does not exist yet, go ahead
  def execute(%Media{id: nil}, %CreateMedia{id: id, name: name, release_date: release_date}) do
    %MediaCreated{id: id, name: name, release_date: release_date}
  end
  # -> Else, when media already exists, fail
  def execute(%Media{}, %CreateMedia{}) do
    {:error, :media_already_exists}
  end

  # Delete media
  # -> ID is required
  def execute(%Media{}, %DeleteMedia{id: nil}) do
    {:error, :id_is_required}
  end
  # TODO: Don't send event if already deleted or not existing, but also don't fail?
  def execute(%Media{}, %DeleteMedia{id: id}) do
    %MediaDeleted{id: id}
  end

  # Add cast
  # -> ID and Actor ID required
  def execute(%Media{}, %AddCast{id: nil}) do
    {:error, :id_is_required}
  end
  def execute(%Media{}, %AddCast{actor_id: nil}) do
    {:error, :actor_id_is_required}
  end
  # -> When media does not exist yet, fail
  def execute(%Media{id: nil}, %AddCast{}) do
    {:error, :actor_does_not_exist}
  end
  # -> Else, when media already exists, send event
  def execute(%Media{}, %AddCast{id: id, actor_id: actor_id}) do
    %CastAdded{id: id, actor_id: actor_id}
  end

  # --- State mutators ---

  # Create media
  def apply(%Media{} = media, %MediaCreated{id: id, name: name, release_date: release_date}) do
    %Media{media |
      id: id,
      name: name,
      release_date: release_date
    }
  end

  # Delete media
  def apply(%Media{}, %MediaDeleted{}) do
    nil
  end

  # Add cast
  def apply(%Media{} = media, %CastAdded{id: id, actor_id: actor_id}) do
    %Media{media |
      cast_actor_ids: [actor_id | List.wrap(media.cast_actor_ids)]
    }
  end
end
alias Ptah.CommandModel.Media

# Router
defmodule Ptah.CommandModel.MediaRouter do
  use Commanded.Commands.Router

  # Media
  dispatch CreateMedia, to: Media, identity: :id
  dispatch DeleteMedia, to: Media, identity: :id
  dispatch AddCast, to: Media, identity: :id
end
