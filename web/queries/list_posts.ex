defmodule Pxblog.Queries.ListPosts do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Pxblog.Post
  alias Pxblog.Repo

  def process(user, params) do
    Post
    |> with_user(user.id)
    |> with_title(params)
    |> with_body(params)
    |> with_tag(params)
    |> with_date(params)
    |> Repo.paginate(params)
  end

  # --------------------- title ------------------------
  defp with_title(query, %{:title => nil}), do: query

  defp with_title(query, %{:title => title}) when is_binary(title) do
    title = "%" <> String.trim(title) <> "%"

    from(i in query,
      where: ilike(i.title, ^title)
    )
  end

  defp with_title(query, _), do: query

  # --------------------- body ------------------------
  defp with_body(query, %{:body => nil}), do: query

  defp with_body(query, %{:body => body}) when is_binary(body) do
    body = "%" <> String.trim(body) <> "%"

    from(i in query,
      where: ilike(i.body, ^body)
    )
  end

  defp with_body(query, _), do: query

  # --------------------- user ------------------------

  defp with_user(query, user_id) do
    from(i in query,
      where: i.user_id == ^user_id
    )
  end

  # --------------------- tag ------------------------
  defp with_tag(query, %{:tag => nil}), do: query

  defp with_tag(query, %{:tag => tag}) when is_binary(tag) do
    tag = "%" <> String.trim(tag) <> "%"

    from(i in query,
      preload: :tags,
      join: tgs in assoc(i, :tags),
      where: ilike(tgs.name, ^tag)
    )
  end

  defp with_tag(query, _), do: query

  # --------------------- date ------------------------
  defp with_date(query, %{:date => nil}), do: query

  defp with_date(query, %{:date => date}) do
    with {:ok, cdate} <- Ecto.Date.cast(date) do
      from(i in query,
        where: fragment("date(inserted_at) = ?", ^cdate)
      )
    end
  end

  defp with_date(query, _), do: query
end
