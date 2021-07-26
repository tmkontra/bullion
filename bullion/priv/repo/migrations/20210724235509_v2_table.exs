defmodule Bullion.Repo.Migrations.V2Table do
  use Ecto.Migration

  def change do
    create table(:table) do
      add :table_id, :string, null: false
      add :name, :string, null: false
      add :buyin_dollars, :integer, null: false
      add :buyin_chips, :integer, null: false
      timestamps([type: :utc_datetime])
    end

    create unique_index(:table, [:table_id])

    create table(:table_player) do
      add :player_id, :string, null: false
      add :name, :string, null: false
      add :table_id, references(:table, on_delete: :nothing), null: false
      timestamps([type: :utc_datetime])
    end

    create unique_index(:table_player, [:player_id])
    create index(:table_player, [:table_id])

    create table(:table_buyin) do
      add :table_id, references(:table, on_delete: :nothing), null: false
      add :player_id, references(:table_player, on_delete: :nothing), null: false
      timestamps([type: :utc_datetime])
    end

    create index(:table_buyin, [:table_id])
    create index(:table_buyin, [:player_id])

    create table(:table_cashout) do
      add :chip_count, :integer, null: false
      add :table_id, references(:table, on_delete: :nothing), null: false
      add :player_id, references(:table_player, on_delete: :nothing), null: false
      timestamps([type: :utc_datetime])
    end

    create index(:table_cashout, [:table_id])
    create index(:table_cashout, [:player_id])
  end
end
