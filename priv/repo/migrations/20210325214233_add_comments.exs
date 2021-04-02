defmodule Discuss.Repo.Migrations.AddComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :content, :string
      add :topic_id, references(:topics)
      add :user_id, references(:users)

      timestamps()
    end
  end
end
