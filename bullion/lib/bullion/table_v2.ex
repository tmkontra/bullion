defmodule Bullion.TableV2 do
  # table persistence

  alias Bullion.Repo
  alias Bullion.TableV2.{Table}
  alias BullionCore.Table, as: CoreTable

  def save_new_table(table) do
    %{
      table_id: table.id,
      name: table.name,
      buyin_chips: table.buyin_chips,
      buyin_dollars: table.buyin_dollars
    }
    |> Table.changeset()
    |> Repo.insert!
    table
  end

  def lookup_table(table_id) do
    Table
    |> Repo.get_by(table_id: table_id)
    |> Repo.preload(:players, players: [:table_buyin, :table_cashout])
    |> case do
      nil -> nil
      record -> record_to_table(record)
    end
  end

  defp record_to_table(record) do
    %Table{
        table_id: table_id,
        name: name,
        buyin_chips: buyin_chips,
        buyin_dollars: buyin_dollars,
        players: players
    } = record
    IO.puts "table has players: #{players}"
    %CoreTable{
      id: table_id,
      name: name,
      buyin_chips: buyin_chips,
      buyin_dollars: buyin_dollars,
      players: players || [],
      buys: [],
      cashouts: []
    }
  end
end
