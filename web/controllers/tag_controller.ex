defmodule Pxblog.TagController do
  use Pxblog.Web, :controller

  alias Pxblog.Tag
  alias Pxblog.Post
  alias Pxblog.RoleChecker
  # to replace empty string with nil
  plug(:scrub_params, "tag" when action in [:create, :update])
  plug(:set_post_and_authorize_user when action in [:update, :delete])

  def create(conn, %{"tag" => tag_params, "post_id" => post_id}) do
    post = Repo.get!(Post, post_id) |> Repo.preload([:user, :tags, :comments, :likes])

    changeset =
      post
      |> build_assoc(:tags)
      |> Tag.changeset(tag_params)

    case Repo.insert(changeset) do
      {:ok, _tag} ->
        conn
        |> put_flash(:info, "Tag created successfully!")
        |> redirect(to: user_post_path(conn, :show, post.user, post))

      {:error, changeset} ->
        render(conn, Pxblog.PostView, "show.html",
          post: post,
          user: post.user,
          comment_changeset: changeset
        )
    end
  end

  def update(conn, %{"id" => id, "post_id" => post_id, "tag" => tag_params}) do
    post = Repo.get!(Post, post_id) |> Repo.preload([:user, :tags, :comments, :likes])
    tag = Repo.get!(Tag, id)
    changeset = Tag.changeset(tag, tag_params)

    case Repo.update(changeset) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Tag updated successfully.")
        |> redirect(to: user_post_path(conn, :show, post.user, post))

      {:error, _} ->
        conn
        |> put_flash(:info, "Failed to update tag!")
        |> redirect(to: user_post_path(conn, :show, post.user, post))
    end
  end

  def delete(conn, %{"id" => id, "post_id" => post_id}) do
    post = Repo.get!(Post, post_id) |> Repo.preload([:user, :tags, :comments, :likes])
    Repo.get!(Tag, id) |> Repo.delete!()

    conn
    |> put_flash(:info, "Deleted tag!")
    |> redirect(to: user_post_path(conn, :show, post.user, post))
  end

  defp set_post(conn) do
    post =
      Repo.get!(Post, conn.params["post_id"]) |> Repo.preload([:user, :tags, :comments, :likes])

    assign(conn, :post, post)
  end

  defp set_post_and_authorize_user(conn, _opts) do
    conn = set_post(conn)

    if is_authorized_user?(conn) do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized to modify that tag!")
      |> redirect(to: page_path(conn, :index))
      |> halt
    end
  end

  defp is_authorized_user?(conn) do
    user = get_session(conn, :current_user)
    post = conn.assigns[:post]
    user && (user.id == post.user_id || RoleChecker.is_admin?(user))
  end
end
