defmodule Pxblog.LayoutViewTest do
  use Pxblog.ConnCase, async: true
  alias Pxblog.LayoutView
  alias Pxblog.TestHelper

  setup do
    {:ok, role} = TestHelper.create_role(%{name: "User Role", admin: false})

    {:ok, user} =
      TestHelper.create_user(role, %{
        email: "test@test.com",
        username: "testuser",
        password: "test",
        password_confirmation: "test"
      })

    {:ok, conn: build_conn(), user: user}
  end

  test "current user returns the user in the session", %{conn: conn, user: user} do
    conn =
      post(conn, session_path(conn, :create),
        user: %{username: user.username, password: user.password}
      )

    assert LayoutView.current_user(conn)
  end

  test "current user returns nothing if there is no user in the session (delete session)", %{
    conn: conn,
    user: user
  } do
    conn = delete(conn, session_path(conn, :delete, user))
    refute LayoutView.current_user(conn)
  end

  test "current user returns nothing if there is no user in the session (incorrect password)", %{
    conn: conn
  } do
    conn = post(conn, session_path(conn, :create), user: %{username: "test", password: "wrong"})
    refute LayoutView.current_user(conn)
  end

  test "current user returns nothing if there is no user in the session (incorrect username)", %{
    conn: conn
  } do
    conn = post(conn, session_path(conn, :create), user: %{username: "wrong", password: "test"})
    refute LayoutView.current_user(conn)
  end
end
