defmodule Pxblog.PostController do
  use Pxblog.Web, :controller

  alias Pxblog.Post
  alias Pxblog.Queries.ListPosts

  plug(:assign_user)
  plug(:authorize_user when action in [:new, :create, :update, :edit, :delete])
  plug(:set_authorization_flag)

  defmodule IndexSearchParams do
    use Params.Schema, %{
      title: :string,
      body: :string,
      tag: :string,
      date: :string,
      page!: :integer,
      page_size!: :integer
    }
  end

  def index(conn, params) do
    with {:ok, params} <- ApplyParams.do_apply(IndexSearchParams, params) do
      posts = ListPosts.process(conn.assigns[:user], params)
      render(conn, "index.html", posts: posts)
    end
  end

  def new(conn, _params) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:posts)
      |> Post.changeset()

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:posts)
      |> Post.changeset(post_params)

    case Repo.insert(changeset) do
      {:ok, _post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: user_post_path(conn, :index, conn.assigns[:user]))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post =
      Repo.get!(assoc(conn.assigns[:user], :posts), id)
      |> Repo.preload([:comments, :likes, :tags, :user])

    comment_changeset =
      post
      |> build_assoc(:comments)
      |> Pxblog.Comment.changeset()

    like_changeset =
      post
      |> build_assoc(:likes)
      |> Pxblog.Like.changeset()

    render(conn, "show.html",
      post: post,
      comment_changeset: comment_changeset,
      like_changeset: like_changeset
    )
  end

  def edit(conn, %{"id" => id}) do
    post =
      Repo.get!(assoc(conn.assigns[:user], :posts), id)
      |> Repo.preload([:comments, :likes, :tags, :user])

    changeset = Post.changeset(post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post =
      Repo.get!(assoc(conn.assigns[:user], :posts), id)
      |> Repo.preload([:comments, :likes, :tags, :user])

    changeset = Post.changeset(post, post_params)

    case Repo.update(changeset) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: user_post_path(conn, :show, conn.assigns[:user], post))

      {:error, changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Repo.get!(assoc(conn.assigns[:user], :posts), id)

    Repo.delete!(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: user_post_path(conn, :index, conn.assigns[:user]))
  end

  defp set_authorization_flag(conn, _opts) do
    assign(conn, :author_or_admin, is_authorized_user?(conn))
  end

  defp is_authorized_user?(conn) do
    user = get_session(conn, :current_user)

    user &&
      (Integer.to_string(user.id) == conn.params["user_id"] || Pxblog.RoleChecker.is_admin?(user))
  end

  defp assign_user(conn, _opts) do
    case conn.params do
      %{"user_id" => user_id} ->
        case Repo.get(Pxblog.User, user_id) do
          nil -> invalid_user(conn)
          user -> assign(conn, :user, user)
        end

      _ ->
        invalid_user(conn)
    end
  end

  defp invalid_user(conn) do
    conn
    |> put_flash(:error, "Invalid user!")
    |> redirect(to: page_path(conn, :index))
    |> halt
  end

  defp authorize_user(conn, _opts) do
    if is_authorized_user?(conn) do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized to modify that post!")
      |> redirect(to: page_path(conn, :index))
      |> halt()
    end
  end
end
