defmodule Pxblog.LikeTest do
  use Pxblog.ModelCase

  alias Pxblog.Like

  import Pxblog.Factory

  @valid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Like.changeset(%Like{}, @valid_attrs)
    assert changeset.valid?
  end

  test "creates a like associated with a post (mark other as nil)" do
    like = insert(:like, comment: nil)
    assert like.post_id
  end

  test "creates a like associated with a comment (mark other as nil)" do
    like = insert(:like, post: nil)
    assert like.comment_id
  end

  test "creates a like associated with a post" do
    like = insert(:like)
    assert like.post_id
  end

  test "creates a like associated with a comment" do
    like = insert(:like)
    assert like.comment_id
  end
end
