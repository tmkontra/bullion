defmodule Bullion.TableV2.Buyin do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]

  schema "table_buyin" do
    field :table_id, :id
    field :player_id, :id

    timestamps()
  end

  @doc false
  def changeset(buyin, attrs) do
    buyin
    |> cast(attrs, [])
    |> validate_required([])
  end
end
