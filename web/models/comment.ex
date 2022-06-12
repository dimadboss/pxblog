defmodule Pxblog.Comment do
  use Pxblog.Web, :model

  schema "comments" do
    field(:author, :string)
    field(:body, :string)
    field(:approved, :boolean, default: false)
    belongs_to(:post, Pxblog.Post)
    has_many(:likes, Pxblog.Like)
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:author, :body, :approved])
    |> assoc_constraint(:post)
    |> validate_required([:author, :body, :approved])
  end
end
