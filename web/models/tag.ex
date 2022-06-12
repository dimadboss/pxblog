defmodule Pxblog.Tag do
  use Pxblog.Web, :model

  schema "tags" do
    field(:name, :string)
    many_to_many(:posts, EctoAssoc.Post, join_through: "posts_tags")
    timestamps()
  end
end
