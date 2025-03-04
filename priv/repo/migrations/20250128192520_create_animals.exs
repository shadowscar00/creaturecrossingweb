defmodule CreatureCrossingWeb.Repo.Migrations.CreateAnimals do
  use Ecto.Migration

  def change do
    create table(:animals) do

      timestamps(type: :utc_datetime)
    end
  end
end
