defmodule Pxblog.UserTest do
  use Pxblog.ModelCase

  alias Pxblog.User

  @valid_attrs %{
    email: "some content",
    password: "test1234",
    password_confirmation: "test1234",
    username: "some content"
  }
  @invalid_attrs %{}

  test "password_digest value gets set to a hash" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert get_change(changeset, :password_digest) == "ABCDE"
  end
  
  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
