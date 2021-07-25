defmodule Bullion.TableV2.Table do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bullion.TableV2.{Player}

  @timestamps_opts [type: :utc_datetime]

  schema "table" do
    field :table_id, :string
    field :name, :string
    field :buyin_chips, :integer
    field :buyin_dollars, :integer

    has_many :players, Player

    timestamps()
  end

  @doc false
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:table_id, :name, :buyin_dollars, :buyin_chips])
    |> validate_required([:table_id, :name, :buyin_dollars, :buyin_chips])
    |> unique_constraint(:table_id)
  end
end
