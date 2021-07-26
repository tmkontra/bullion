defmodule Bullion.TableV2.Buyin do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bullion.TableV2.{Player, Table}
  @timestamps_opts [type: :utc_datetime]

  schema "table_buyin" do

    belongs_to :player, Player
    belongs_to :table, Table

    timestamps()
  end

  @doc false
  def changeset(buyin, attrs) do
    buyin
    |> cast(attrs, [:player_id, :table_id])
    |> validate_required([:player_id, :table_id])
  end
end
