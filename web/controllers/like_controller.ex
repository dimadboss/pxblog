defmodule Pxblog.LikeController do
  use Pxblog.Web, :controller
  alias Pxblog.Like
  alias Pxblog.Post

  def create(conn, %{"like" => like_params, "post_id" => post_id}) do
    post = Repo.get!(Post, post_id) |> Repo.preload([:user, :comments])
    current_user = Plug.Conn.get_session(conn, :current_user)

    changeset =
      post
      |> build_assoc(:likes, user_id: current_user.id)
      |> Like.changeset(like_params)

    case Repo.insert(changeset) do
      {:ok, _like} ->
        conn
        |> put_flash(:info, "Like created successfully!")
        |> redirect(to: user_post_path(conn, :update, post.user, post))

      {:error, changeset} ->
        render(conn, Pxblog.PostView, "show.html",
          post: post,
          user: post.user,
          like_changeset: changeset
        )
    end
  end
end
