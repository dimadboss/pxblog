defmodule Pxblog.Repo.Migrations.CreateLike do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:likes) do
      add :user_id, references(:users, on_delete: :nothing)
      add :post_id, references(:posts, on_delete: :nothing)
      add :comment_id, references(:comments, on_delete: :nothing)

      timestamps()
    end
    create_if_not_exists index(:likes, [:user_id])
    create_if_not_exists index(:likes, [:post_id])
    create_if_not_exists index(:likes, [:comment_id])

  end
end
