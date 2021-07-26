defmodule Bullion.TableV2.Cashout do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bullion.TableV2.{Player, Table}

  @timestamps_opts [type: :utc_datetime]

  schema "table_cashout" do
    field :chip_count, :integer

    belongs_to :player, Player
    belongs_to :table, Table

    timestamps()
  end

  @doc false
  def changeset(cashout, attrs) do
    cashout
    |> cast(attrs, [:chip_count, :player_id, :table_id])
    |> validate_required([:chip_count, :player_id, :table_id])
  end
end
