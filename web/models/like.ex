defmodule Pxblog.Like do
  use Pxblog.Web, :model

  schema "likes" do
    belongs_to :user, Pxblog.User
    belongs_to :post, Pxblog.Post
    belongs_to :comment, Pxblog.Comment

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> validate_required([])
  end
end
