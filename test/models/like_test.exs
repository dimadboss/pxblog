defmodule Pxblog.LikeTest do
  use Pxblog.ModelCase

  alias Pxblog.Like
  alias Pxblog.Post
  alias Pxblog.Comment

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

  test "creates a like associated with a post and check like count" do
    post = insert(:post) |> Repo.preload(:likes)
    assert length(post.likes) == 0
    like = insert(:like, post: post, comment: nil)
    post = Repo.get!(Post, like.post_id) |> Repo.preload(:likes)
    assert length(post.likes) == 1
    assert hd(post.likes).post_id == like.post_id
  end

  test "creates two likes associated with a post and check like count" do
    post = insert(:post) |> Repo.preload(:likes)
    assert length(post.likes) == 0
    like = insert(:like, post: post, comment: nil)
    insert(:like, post: post, comment: nil)
    post = Repo.get!(Post, like.post_id) |> Repo.preload(:likes)
    assert length(post.likes) == 2
  end

  test "creates a like associated with a comment and check like count" do
    comment = insert(:comment) |> Repo.preload(:likes)
    assert length(comment.likes) == 0
    like = insert(:like, post: nil, comment: comment)
    comment = Repo.get!(Comment, like.comment_id) |> Repo.preload(:likes)
    assert length(comment.likes) == 1
    assert hd(comment.likes).comment_id == like.comment_id
  end

  test "creates two likes associated with a comment and check like count" do
    comment = insert(:comment) |> Repo.preload(:likes)
    assert length(comment.likes) == 0
    like = insert(:like, post: nil, comment: comment)
    insert(:like, post: nil, comment: comment)
    comment = Repo.get!(Comment, like.comment_id) |> Repo.preload(:likes)
    assert length(comment.likes) == 2
  end
end
