defmodule Pxblog.TagTest do
  use Pxblog.ModelCase

  alias Pxblog.Tag

  import Pxblog.Factory

  @valid_attrs %{name: "Test Tag"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Tag.changeset(%Tag{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Tag.changeset(%Tag{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "creates a tag associated with posts" do
    tag = insert(:tag)
    assert tag.posts
    first_post = hd(tag.posts) |> Repo.preload(:tags)
    assert first_post.title == "Some Post"
    assert hd(first_post.tags).name == "Test Tag"
    assert hd(first_post.tags).id == tag.id
  end
end
