defmodule Bullion.Player do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]

  schema "player" do
    field :name, :string
    field :buyin_count, :integer
    belongs_to :game, Bullion.Game
    has_many :cashouts, Bullion.CashOut
    timestamps()
  end

  def changeset(player, params \\ %{}) do
    player
    |> Ecto.Changeset.cast(params, [:name, :buyin_count, :game_id])
    |> Ecto.Changeset.validate_required([:name, :buyin_count, :game_id])
  end
end
