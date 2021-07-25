defmodule Bullion.TableV2 do
  # table persistence

  alias Ecto
  alias Bullion.Repo
  alias Bullion.TableV2.{Table, Player, Buyin, Cashout}
  alias BullionCore, as: Core

  defguard table_player(table_id, player_id) when is_binary(table_id) and is_binary(player_id)

  def save_new_table(%Core.Table{} = table) do
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
    |> Repo.preload([players: [:buyins, :cashouts]])
    |> case do
      nil -> nil
      record -> record_to_table(record)
    end
  end

  def save_player(table_id, %Core.Player{name: name, id: player_id} = _player) when is_binary(table_id) do
    Table
    |> Repo.get_by!(table_id: table_id)
    |> Ecto.build_assoc(:players, %{name: name, player_id: to_string(player_id)})
    |> Repo.insert!
  end

  def save_buyin(table_id, player_id) when table_player(table_id, player_id) do
    with {:ok, player, table} <- find_player_at_table(table_id, player_id) do
      player
      |> Ecto.build_assoc(:buyins)
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:table, table)
      |> Repo.insert!
    end
  end

  def save_cashout(table_id, player_id, chip_count) when table_player(table_id, player_id) and is_integer(chip_count) do
    with {:ok, player, table} <- find_player_at_table(table_id, player_id) do
      player
      |> Ecto.build_assoc(:cashouts)
      |> Ecto.Changeset.change(%{chip_count: chip_count})
      |> Ecto.Changeset.put_assoc(:table, table)
      |> Repo.insert!
    end
  end

  defp find_player_at_table(table_id, player_id) do
    %Table{players: players} = table = Table
    |> Repo.get_by!(table_id: table_id)
    |> Repo.preload(:players)
    case Enum.find(players, fn (player) -> player.player_id == player_id end) do
      nil -> {:error, "No player #{player_id} for table #{table_id}"}
      player -> {:ok, player, table}
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
    {players, buys, cashouts} = parse_players(players)
    IO.puts "table has #{length(players)} players"
    %Core.Table{
      id: table_id,
      name: name,
      buyin_chips: buyin_chips,
      buyin_dollars: buyin_dollars,
      players: players,
      buys: buys,
      cashouts: cashouts
    }
  end

  defp parse_players(players) do
    players
    |> List.foldl({[], %{}, %{}}, &fold_players/2)
  end

  defp fold_players(
    %Player{name: name, player_id: player_id, buyins: buyins, cashouts: cashouts} = _player,
    acc
  ) do
    player = %Core.Player{name: name, id: player_id}
    player_cashouts = Enum.map(cashouts, fn (c) -> c.chip_count end)
    buyins = length(buyins)
    {players, buys, cashouts} = acc
    buys = Map.put(buys, player_id, buyins)
    cashouts = Map.put(cashouts, player_id, player_cashouts)
    {[player | players], buys, cashouts}
  end
end
