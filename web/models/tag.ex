defmodule Pxblog.Tag do
  use Pxblog.Web, :model

  alias Pxblog.Repo

  schema "tags" do
    field(:name, :string)
    many_to_many(:posts, Pxblog.Post, join_through: "posts_tags")
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, %{"posts" => _} = params) do
    struct
    |> Repo.preload(:posts)
    |> cast(params, [:name])
    |> validate_required([:name])
    |> put_assoc(:posts, params.posts)
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end


end
