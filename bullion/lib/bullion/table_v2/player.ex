defmodule Bullion.TableV2.Player do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bullion.TableV2.{Table, Buyin, Cashout}

  @timestamps_opts [type: :utc_datetime]

  schema "table_player" do
    field :name, :string
    field :player_id, :string

    belongs_to :table, Table
    has_many :table_buyin, Buyin
    has_many :table_cashout, Cashout

    timestamps()
  end

  def changeset(player, attrs) do
    player
    |> cast(attrs, [:player_id, :name, :table_id])
    |> validate_required([:player_id, :name, :table_id])
    |> unique_constraint(:player_id)
  end
end
