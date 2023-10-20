defmodule Ptah.ReadModel.MediaList.Schema do
  use Ecto.Schema

  schema "media_list" do
    field(:media_id, :string)
    field(:name, :string)
    field(:cast_names, {:array, :string})
  end
end

defmodule Ptah.ReadModel.MediaList.Projection do
  use Commanded.Projections.Ecto, name: to_string(__MODULE__)

  # Media created
  project(
    %Ptah.CommandModel.MediaCreated{id: id, name: name, release_date: release_date},
    fn multi ->
      media = query_by_id(id)

      case media do
        nil ->
          item = %Ptah.ReadModel.MediaList.Schema{media_id: id, name: name}
          Ecto.Multi.insert(multi, :create_media_list, item)

        saved ->
          changeset =
            saved
            |> Ecto.Changeset.change()
            |> Ecto.Changeset.put_change(:name, name)

          Ecto.Multi.update(multi, :update_media_list_name, changeset)
      end
    end
  )

  # Media deleted
  project(
    %Ptah.CommandModel.MediaDeleted{id: id},
    fn multi ->
      media = query_by_id(id)

      case media do
        nil -> {:ok, "already deleted"}
        saved -> Ecto.Multi.delete(multi, :update_media_list_name, saved)
      end
    end
  )

  # -- helpers --

  defp query_by_id(id) do
    from(
      m in Ptah.ReadModel.MediaList.Schema,
      where: m.id == ^id
    )
    |> Ptah.Repo.one()
  end
end
