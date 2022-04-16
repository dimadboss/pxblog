defmodule Pxblog.User do
  use Pxblog.Web, :model

  schema "users" do
    field(:username, :string)
    field(:email, :string)
    field(:password_digest, :string)

    # Virtual Fields
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :email, :password, :password_confirmation])
    |> validate_required([:username, :email, :password, :password_confirmation])
    |> hash_password
  end

  defp hash_password(changeset) do
    changeset
    |> put_change(:password_digest, "ABCDE")
  end
end
