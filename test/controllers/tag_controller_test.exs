defmodule Pxblog.TagControllerTest do
  use Pxblog.ConnCase
  import Pxblog.Factory
  alias Pxblog.Tag

  @valid_attrs %{name: "Test Tag"}
  @invalid_attrs %{}

  setup do
    user = insert(:user)
    tag = insert(:tag)
    post = insert(:post, user: user, tags: [tag])
    {:ok, conn: build_conn(), user: user, post: post, tag: tag}
  end

  test "creates resource and redirects when data is valid", %{conn: conn, post: post} do
    conn = post(conn, post_tag_path(conn, :create, post), tag: @valid_attrs)
    assert redirected_to(conn) == user_post_path(conn, :show, post.user, post)
    assert Repo.get_by(assoc(post, :tags), @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{
    conn: conn,
    post: post
  } do
    conn = post(conn, post_tag_path(conn, :create, post), tag: @invalid_attrs)
    assert html_response(conn, 200) =~ "Oops, something went wrong"
  end

  defp login_user(conn, user) do
    post(conn, session_path(conn, :create),
      user: %{username: user.username, password: user.password}
    )
  end

  test "does not delete the tag when not logged in as an authorized user", %{
    conn: conn,
    post: post,
    tag: tag
  } do
    conn = delete(conn, post_tag_path(conn, :delete, post, tag))
    assert redirected_to(conn) == page_path(conn, :index)
    assert Repo.get(Tag, tag.id)
  end

  test "updates chosen resource and redirects when data is valid and logged in as the author", %{
    conn: conn,
    user: user,
    post: post,
    tag: tag
  } do
    conn =
      login_user(conn, user)
      |> put(post_tag_path(conn, :update, post, tag), tag: %{"name" => "new name"})

    assert redirected_to(conn) == user_post_path(conn, :show, user, post)
    assert Repo.get_by(Tag, %{id: tag.id, name: "new name"})
  end

  test "does not update chosen resource and redirects when data is invalid and logged in as the author",
       %{
         conn: conn,
         user: user,
         post: post,
         tag: tag
       } do
    conn =
      login_user(conn, user)
      |> put(post_tag_path(conn, :update, post, tag), tag: @invalid_attrs)

    assert redirected_to(conn) == user_post_path(conn, :show, user, post)
    assert Repo.get_by(Tag, %{id: tag.id, name: "Test Tag"})
  end

  test "does not update the tag when not logged in as an authorized user", %{
    conn: conn,
    post: post,
    tag: tag
  } do
    conn = put(conn, post_tag_path(conn, :update, post, tag), tag: %{"name" => "new name"})

    assert redirected_to(conn) == page_path(conn, :index)
    refute Repo.get_by(Tag, %{id: tag.id, name: "new name"})
  end
end
