defmodule Pxblog.Factory do
  use ExMachina.Ecto, repo: Pxblog.Repo

  alias Pxblog.Role
  alias Pxblog.User
  alias Pxblog.Post

  def role_factory do
    %Role{
      name: sequence(:name, &"Test Role #{&1}"),
      admin: false
    }
  end

  def user_factory do
    %User{
      username: sequence(:username, &"User #{&1}"),
      email: "test@test.com",
      password: "test1234",
      password_confirmation: "test1234",
      password_digest: Comeonin.Bcrypt.hashpwsalt("test1234"),
      role: build(:role)
    }
  end
end
