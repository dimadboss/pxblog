defmodule Pxblog.PostControllerTest do
  use Pxblog.ConnCase

  import Pxblog.Factory

  alias Pxblog.Post
  @valid_attrs %{body: "some content", title: "some content"}
  @invalid_attrs %{body: nil}

  setup do
    role = insert(:role)
    admin_role = insert(:role, admin: true)
    admin_user = insert(:user, role: admin_role)
    user = insert(:user, role: role)
    other_user = insert(:user, role: role)

    post = insert(:post, user: user)


    post_for_tag = insert(:post, user: user)
    tag = insert(:tag, posts: [post_for_tag])

    conn = build_conn() |> login_user(user)

    {:ok,
     conn: conn,
     user: user,
     other_user: other_user,
     admin_user: admin_user,
     role: role,
     post: post,
     tag: tag}
  end

  defp login_user(conn, user) do
    post(conn, session_path(conn, :create),
      user: %{username: user.username, password: user.password}
    )
  end

  defp logout_user(conn, user) do
    delete(conn, session_path(conn, :delete, user))
  end

  test "lists all entries on index", %{conn: conn, user: user} do
    conn = get(conn, user_post_path(conn, :index, user))
    assert html_response(conn, 200) =~ "Listing posts"
    assert html_response(conn, 200) =~ "Some Post"
  end

  test "lists all entries on index with tag search query", %{conn: conn, user: user, tag: tag} do
    conn = get(conn, user_post_path(conn, :index, user, %{tag: tag.name}))
    assert html_response(conn, 200) =~ "Listing posts"
    assert html_response(conn, 200) =~ "Some Post"
  end

  test "lists all entries on index with tag search query (no posts)", %{conn: conn, user: user} do
    conn = get(conn, user_post_path(conn, :index, user, %{tag: "fake tag"}))
    assert html_response(conn, 200) =~ "Listing posts"
    refute html_response(conn, 200) =~ "Some Post"
  end

  test "lists all entries on index with user search query", %{conn: conn, user: user} do
    conn = get(conn, user_post_path(conn, :index, user, %{user: "Usernametext"}))
    assert html_response(conn, 200) =~ "Listing posts"
    assert html_response(conn, 200) =~ "Some Post"
  end

  test "lists all entries on index with user search query (no posts)", %{conn: conn, user: user} do
    conn = get(conn, user_post_path(conn, :index, user, %{user: "Noone"}))
    assert html_response(conn, 200) =~ "Listing posts"
    refute html_response(conn, 200) =~ "Some Post"
  end

  test "lists all entries on index with title search query", %{conn: conn, user: user} do
    conn = get(conn, user_post_path(conn, :index, user, %{title: "Some Post"}))
    assert html_response(conn, 200) =~ "Listing posts"
    assert html_response(conn, 200) =~ "Some Post"
  end

  test "lists all entries on index with title search query (no posts)", %{conn: conn, user: user} do
    conn = get(conn, user_post_path(conn, :index, user, %{title: "Some Other Post"}))
    assert html_response(conn, 200) =~ "Listing posts"
    refute html_response(conn, 200) =~ "Some Post"
  end

  test "lists all entries on index with body search query", %{conn: conn, user: user} do
    conn = get(conn, user_post_path(conn, :index, user, %{body: "And the body of some post"}))
    assert html_response(conn, 200) =~ "Listing posts"
    assert html_response(conn, 200) =~ "And the body of some post"
  end

  test "lists all entries on index with body search query (no posts)", %{conn: conn, user: user} do
    conn =
      get(conn, user_post_path(conn, :index, user, %{title: "And other the body of some post"}))

    assert html_response(conn, 200) =~ "Listing posts"
    refute html_response(conn, 200) =~ "And the body of some post"
  end

  test "renders form for new resources", %{conn: conn, user: user} do
    conn = get(conn, user_post_path(conn, :new, user))
    assert html_response(conn, 200) =~ "New post"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, user: user} do
    conn = post(conn, user_post_path(conn, :create, user), post: @valid_attrs)
    assert redirected_to(conn) == user_post_path(conn, :index, user)
    assert Repo.get_by(assoc(user, :posts), @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{
    conn: conn,
    user: user
  } do
    conn = post(conn, user_post_path(conn, :create, user), post: @invalid_attrs)
    assert html_response(conn, 200) =~ "New post"
  end

  test "when logged in as the author, shows chosen resource with author flag set to true", %{
    conn: conn,
    user: user,
    post: post
  } do
    conn = login_user(conn, user) |> get(user_post_path(conn, :show, user, post))
    assert html_response(conn, 200) =~ "Show post"
    assert conn.assigns[:author_or_admin]
  end

  test "when logged in as an admin, shows chosen resource with author flag set to true", %{
    conn: conn,
    user: user,
    admin_user: admin_user,
    post: post
  } do
    conn = login_user(conn, admin_user) |> get(user_post_path(conn, :show, user, post))
    assert html_response(conn, 200) =~ "Show post"
    assert conn.assigns[:author_or_admin]
  end

  test "when not logged in, shows chosen resource with author flag set to false", %{
    conn: conn,
    user: user,
    post: post
  } do
    conn = logout_user(conn, user) |> get(user_post_path(conn, :show, user, post))
    assert html_response(conn, 200) =~ "Show post"
    refute conn.assigns[:author_or_admin]
  end

  test "when logged in as a different user, shows chosen resource with author flag set to false",
       %{conn: conn, user: user, other_user: other_user, post: post} do
    conn = login_user(conn, other_user) |> get(user_post_path(conn, :show, user, post))
    assert html_response(conn, 200) =~ "Show post"
    refute conn.assigns[:author_or_admin]
  end

  test "renders page not found when id is nonexistent", %{conn: conn, user: user} do
    assert_error_sent(404, fn ->
      get(conn, user_post_path(conn, :show, user, -1))
    end)
  end

  test "renders form for editing chosen resource", %{conn: conn, user: user, post: post} do
    conn = get(conn, user_post_path(conn, :edit, user, post))
    assert html_response(conn, 200) =~ "Edit post"
  end

  test "updates chosen resource and redirects when data is valid", %{
    conn: conn,
    user: user,
    post: post
  } do
    conn = put(conn, user_post_path(conn, :update, user, post), post: @valid_attrs)
    assert redirected_to(conn) == user_post_path(conn, :show, user, post)
    assert Repo.get_by(Post, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{
    conn: conn,
    user: user,
    post: post
  } do
    conn = put(conn, user_post_path(conn, :update, user, post), post: @invalid_attrs)
    assert html_response(conn, 200) =~ "Edit post"
  end

  test "deletes chosen resource", %{conn: conn, user: user, post: post} do
    conn = delete(conn, user_post_path(conn, :delete, user, post))
    # after delete returns to index page
    assert redirected_to(conn) == user_post_path(conn, :index, user)
    # make sure post does not exist now
    refute Repo.get(Post, post.id)
  end

  test "redirects when the specified user does not exist", %{conn: conn} do
    conn = get(conn, user_post_path(conn, :index, -1))
    assert get_flash(conn, :error) == "Invalid user!"
    assert redirected_to(conn) == page_path(conn, :index)
    assert conn.halted
  end

  test "redirects when trying to edit a post for a different user", %{
    conn: conn,
    other_user: other_user,
    post: post
  } do
    conn = get(conn, user_post_path(conn, :edit, other_user, post))
    assert get_flash(conn, :error) == "You are not authorized to modify that post!"
    assert redirected_to(conn) == page_path(conn, :index)
    assert conn.halted
  end

  test "redirects when trying to delete a post for a different user", %{
    conn: conn,
    other_user: other_user,
    post: post
  } do
    conn = delete(conn, user_post_path(conn, :delete, other_user, post))
    assert get_flash(conn, :error) == "You are not authorized to modify that post!"
    assert redirected_to(conn) == page_path(conn, :index)
    assert conn.halted
  end

  test "redirects when trying to update a post for a different user", %{
    conn: conn,
    other_user: other_user,
    post: post
  } do
    conn = put(conn, user_post_path(conn, :update, other_user, post), post: @valid_attrs)
    assert get_flash(conn, :error) == "You are not authorized to modify that post!"
    assert redirected_to(conn) == page_path(conn, :index)
    assert conn.halted
  end

  test "redirects when trying to delete a post for a different user (other user)", %{
    conn: conn,
    post: post,
    other_user: other_user
  } do
    conn = delete(conn, user_post_path(conn, :delete, other_user, post))
    assert get_flash(conn, :error) == "You are not authorized to modify that post!"
    assert redirected_to(conn) == page_path(conn, :index)
    assert conn.halted
  end

  test "renders form for editing chosen resource when logged in as admin", %{
    conn: conn,
    user: user,
    post: post,
    admin_user: admin_user
  } do
    conn =
      login_user(conn, admin_user)
      |> get(user_post_path(conn, :edit, user, post))

    assert html_response(conn, 200) =~ "Edit post"
  end

  test "updates chosen resource and redirects when data is valid when logged in as admin", %{
    conn: conn,
    user: user,
    post: post,
    admin_user: admin_user
  } do
    conn =
      login_user(conn, admin_user)
      |> put(user_post_path(conn, :update, user, post), post: @valid_attrs)

    assert redirected_to(conn) == user_post_path(conn, :show, user, post)
    assert Repo.get_by(Post, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid when logged in as admin",
       %{conn: conn, user: user, post: post, admin_user: admin_user} do
    conn =
      login_user(conn, admin_user)
      |> put(user_post_path(conn, :update, user, post), post: %{"body" => nil})

    assert html_response(conn, 200) =~ "Edit post"
  end

  test "deletes chosen resource when logged in as admin", %{
    conn: conn,
    user: user,
    post: post,
    admin_user: admin_user
  } do
    conn =
      login_user(conn, admin_user)
      |> delete(user_post_path(conn, :delete, user, post))

    assert redirected_to(conn) == user_post_path(conn, :index, user)
    refute Repo.get(Post, post.id)
  end
end
