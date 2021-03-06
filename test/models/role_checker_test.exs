defmodule Pxblog.RoleCheckerTest do
  use Pxblog.ModelCase
  import Pxblog.Factory
  alias Pxblog.RoleChecker

  test "is_admin? is true when user has an admin role" do
    role = insert(:role, admin: true)
    user = insert(:user, role: role)
    assert RoleChecker.is_admin?(user)
  end

  test "is_admin? is false when user does not have an admin role" do
    role = insert(:role)
    user = insert(:user, role: role)
    refute RoleChecker.is_admin?(user)
  end
end
