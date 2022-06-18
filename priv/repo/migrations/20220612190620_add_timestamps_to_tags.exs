defmodule Pxblog.Repo.Migrations.AddTimestampsToTags do
  use Ecto.Migration

  def change do
    alter table(:tags) do
      timestamps()
    end
  end
end
