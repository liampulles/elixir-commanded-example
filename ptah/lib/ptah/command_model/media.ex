
# --- Commands ---

defmodule Ptah.CommandModel.CreateMedia do
  defstruct [:id, :name, :release_date]
end
alias Ptah.CommandModel.CreateMedia

defmodule Ptah.CommandModel.DeleteMedia do
  defstruct [:id]
end
alias Ptah.CommandModel.DeleteMedia

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

# Aggregate
defmodule Ptah.CommandModel.Media do
  alias Ptah.CommandModel.Media
  defstruct [
    :id,
    :name,
    :release_date
  ]

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
end

# Router
defmodule Ptah.CommandModel.MediaRouter do
  use Commanded.Commands.Router

  # Media
  dispatch CreateMedia, to: Ptah.CommandModel.Media, identity: :id
  dispatch DeleteMedia, to: Ptah.CommandModel.Media, identity: :id
end
