defmodule Pxblog.UserControllerTest do
  use Pxblog.ConnCase

  alias Pxblog.User
  import Pxblog.Factory

  @valid_create_attrs %{
    email: "some content",
    password: "test1234",
    password_confirmation: "test1234",
    username: "some content"
  }
  @valid_attrs %{
    email: "some content",
    username: "some content"
  }
  @invalid_attrs %{}

  setup do
    user_role = insert(:role)
    nonadmin_user = insert(:user, role: user_role)
    other_nonadmin_user = insert(:user, role: user_role)

    admin_role = insert(:role, admin: true)
    admin_user = insert(:user, role: admin_role)

    {:ok,
     conn: build_conn(),
     admin_role: admin_role,
     user_role: user_role,
     nonadmin_user: nonadmin_user,
     other_nonadmin_user: other_nonadmin_user,
     admin_user: admin_user}
  end

  defp login_user(conn, user) do
    post(conn, session_path(conn, :create),
      user: %{username: user.username, password: user.password}
    )
  end

  defp valid_create_attrs(role) do
    Map.put(@valid_create_attrs, :role_id, role.id)
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get(conn, user_path(conn, :index))
    assert html_response(conn, 200) =~ "Listing users"
  end

  @tag admin: true
  test "renders form for new resources", %{conn: conn, admin_user: admin_user} do
    conn =
      conn
      |> login_user(admin_user)
      |> get(user_path(conn, :new))

    assert html_response(conn, 200) =~ "New user"
  end

  @tag admin: true
  test "redirects from new form when not admin", %{conn: conn, nonadmin_user: nonadmin_user} do
    conn = login_user(conn, nonadmin_user)
    conn = get(conn, user_path(conn, :new))
    assert get_flash(conn, :error) == "You are not authorized to create new users!"
    assert redirected_to(conn) == page_path(conn, :index)
    assert conn.halted
  end

  @tag admin: true
  test "creates resource and redirects when data is valid", %{
    conn: conn,
    user_role: user_role,
    admin_user: admin_user
  } do
    conn = login_user(conn, admin_user)
    conn = post(conn, user_path(conn, :create), user: valid_create_attrs(user_role))
    assert redirected_to(conn) == user_path(conn, :index)
    assert Repo.get_by(User, @valid_attrs)
  end

  @tag admin: true
  test "redirects from creating user when not admin", %{
    conn: conn,
    user_role: user_role,
    nonadmin_user: nonadmin_user
  } do
    conn = login_user(conn, nonadmin_user)
    conn = post(conn, user_path(conn, :create), user: valid_create_attrs(user_role))
    assert get_flash(conn, :error) == "You are not authorized to create new users!"
    assert redirected_to(conn) == page_path(conn, :index)
    assert conn.halted
  end

  @tag admin: true
  test "does not create resource and renders errors when data is invalid", %{
    conn: conn,
    admin_user: admin_user
  } do
    conn = login_user(conn, admin_user)
    conn = post(conn, user_path(conn, :create), user: @invalid_attrs)
    assert html_response(conn, 200) =~ "New user"
  end

  test "shows chosen resource", %{conn: conn} do
    user = Repo.insert!(%User{})
    conn = get(conn, user_path(conn, :show, user))
    assert html_response(conn, 200) =~ "Show user"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent(404, fn ->
      get(conn, user_path(conn, :show, -1))
    end)
  end

  @tag admin: true
  test "renders form for editing chosen resource when logged in as that user", %{
    conn: conn,
    nonadmin_user: nonadmin_user
  } do
    conn = login_user(conn, nonadmin_user)
    conn = get(conn, user_path(conn, :edit, nonadmin_user))
    assert html_response(conn, 200) =~ "Edit user"
  end

  @tag admin: true
  test "renders form for editing chosen resource when logged in as an admin", %{
    conn: conn,
    admin_user: admin_user,
    nonadmin_user: nonadmin_user
  } do
    conn = login_user(conn, admin_user)
    conn = get(conn, user_path(conn, :edit, nonadmin_user))
    assert html_response(conn, 200) =~ "Edit user"
  end

  @tag admin: true
  test "redirects away from editing when logged in as a different user", %{
    conn: conn,
    nonadmin_user: nonadmin_user,
    admin_user: admin_user
  } do
    conn = login_user(conn, nonadmin_user)
    conn = get(conn, user_path(conn, :edit, admin_user))
    assert get_flash(conn, :error) == "You are not authorized to modify that user!"
    assert redirected_to(conn) == page_path(conn, :index)
    assert conn.halted
  end

  @tag admin: true
  test "updates chosen resource and redirects when data is valid when logged in as that user", %{
    conn: conn,
    nonadmin_user: nonadmin_user
  } do
    conn = login_user(conn, nonadmin_user)
    conn = put(conn, user_path(conn, :update, nonadmin_user), user: @valid_create_attrs)
    assert redirected_to(conn) == user_path(conn, :show, nonadmin_user)
    assert Repo.get_by(User, @valid_attrs)
  end

  @tag admin: true
  test "updates chosen resource and redirects when data is valid when logged in as an admin", %{
    conn: conn,
    admin_user: admin_user
  } do
    conn = login_user(conn, admin_user)
    conn = put(conn, user_path(conn, :update, admin_user), user: @valid_create_attrs)
    assert redirected_to(conn) == user_path(conn, :show, admin_user)
    assert Repo.get_by(User, @valid_attrs)
  end

  @tag admin: true
  test "does not update chosen resource when logged in as different user", %{
    conn: conn,
    nonadmin_user: nonadmin_user,
    admin_user: admin_user
  } do
    conn = login_user(conn, nonadmin_user)
    conn = put(conn, user_path(conn, :update, admin_user), user: @valid_create_attrs)
    assert get_flash(conn, :error) == "You are not authorized to modify that user!"
    assert redirected_to(conn) == page_path(conn, :index)
    assert conn.halted
  end

  @tag admin: true
  test "does not update chosen resource and renders errors when data is invalid", %{
    conn: conn,
    nonadmin_user: nonadmin_user
  } do
    conn = login_user(conn, nonadmin_user)
    conn = put(conn, user_path(conn, :update, nonadmin_user), user: @invalid_attrs)
    assert html_response(conn, 200) =~ "Edit user"
  end

  @tag admin: true
  test "deletes chosen resource when logged in as that user", %{
    conn: conn,
    nonadmin_user: nonadmin_user
  } do
    conn =
      login_user(conn, nonadmin_user)
      |> delete(user_path(conn, :delete, nonadmin_user))

    assert redirected_to(conn) == user_path(conn, :index)
    refute Repo.get(User, nonadmin_user.id)
  end

  @tag admin: true
  test "deletes chosen resource when logged in as an admin", %{
    conn: conn,
    admin_user: admin_user,
    nonadmin_user: nonadmin_user
  } do
    conn =
      login_user(conn, admin_user)
      |> delete(user_path(conn, :delete, nonadmin_user))

    assert redirected_to(conn) == user_path(conn, :index)
    refute Repo.get(User, nonadmin_user.id)
  end

  @tag admin: true
  test "redirects away from deleting chosen resource when logged in as a different user", %{
    conn: conn,
    nonadmin_user: nonadmin_user,
    other_nonadmin_user: other_nonadmin_user
  } do
    conn =
      login_user(conn, nonadmin_user)
      |> delete(user_path(conn, :delete, other_nonadmin_user))

    assert get_flash(conn, :error) == "You are not authorized to modify that user!"
    assert redirected_to(conn) == page_path(conn, :index)
    assert conn.halted
  end
end
