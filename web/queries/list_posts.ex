defmodule Pxblog.Queries.ListPosts do
  @moduledoc false

  import Ecto.Query, only: [from: 2]

  alias Pxblog.Post
  alias Pxblog.Repo

  def process(params) do
    Post
    |> with_title(params)
    |> with_body(params)
    |> with_user(params)
    |> Repo.all()
  end

  # --------------------- title ------------------------
  defp with_title(query, %{"title" => nil}), do: query

  defp with_title(query, %{"title" => title}) when is_binary(title) do
    title = "%" <> String.trim(title) <> "%"

    from(i in query,
      where: ilike(i.title, ^title)
    )
  end

  defp with_title(query, _), do: query

  # --------------------- body ------------------------
  defp with_body(query, %{"body" => nil}), do: query

  defp with_body(query, %{"body" => body}) when is_binary(body) do
    body = "%" <> String.trim(body) <> "%"

    from(i in query,
      where: ilike(i.body, ^body)
    )
  end

  defp with_body(query, _), do: query

  # --------------------- user ------------------------
  defp with_user(query, %{"user" => nil}), do: query

  defp with_user(query, %{"user" => user}) when is_binary(user) do
    user = "%" <> String.trim(user) <> "%"

    from(i in query,
      preload: :user,
      join: usr in assoc(i, :user),
      where: ilike(usr.username, ^user)
    )
  end

  defp with_user(query, _), do: query
end
