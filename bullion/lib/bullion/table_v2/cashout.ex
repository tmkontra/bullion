defmodule Bullion.TableV2.Cashout do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]

  schema "table_cashout" do
    field :chip_count, :integer
    field :table_id, :id
    field :player_id, :id

    timestamps()
  end

  @doc false
  def changeset(cashout, attrs) do
    cashout
    |> cast(attrs, [:chip_count])
    |> validate_required([:chip_count])
  end
end
