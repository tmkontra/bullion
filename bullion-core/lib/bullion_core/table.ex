defmodule BullionCore.Table do
  defstruct ~w[id name buyin_dollars buyin_chips players buys cashouts]a

  alias BullionCore.Player
  alias BullionCore

  def new(fields) do
    defaults = %{players: [], buys: %{}, cashouts: %{}}
    fields = Map.merge(fields, defaults)
    struct!(__MODULE__, fields)
  end

  def generate_table_id(_args) do
    Base.encode16(:crypto.strong_rand_bytes(8))
  end

  def add_player(table, name) do
    new_id = length(table.players) + 1 # TODO: use UUID
    player = Player.new(new_id, name)
    players = [player | table.players]
    {new_id, %{table | players: players}}
  end

  def buyin(table, player_id) do
    with {:ok, p} <- get_player(table, player_id),
         table <- add_buy(table, player_id)
    do
      {p, table}
    end
  end

  def cashout(table, player_id, chips) do
    with {:ok, p} <- get_player(table, player_id),
         table <- add_cashout(table, player_id, chips)
    do
      {p, table}
    end
  end

  defp add_cashout(table, player_id, chips) do
    existing_cashouts = Map.get(table.cashouts, player_id, [])
    player_cashouts = [chips | existing_cashouts]
    cashouts = Map.put(table.cashouts, player_id, player_cashouts)
    %{table | cashouts: cashouts}
  end

  defp add_buy(table, player_id) do
    existing_buys = Map.get(table.buys, player_id, 0)
    buys = Map.put(table.buys, player_id, existing_buys + 1)
    %{table | buys: buys}
  end

  def get_player(table, player_id) do
    table.players
      |> Enum.find(fn p -> p.id == player_id end)
      |> case do
        nil -> {:error, "not found"}
        p -> {:ok, p}
      end
  end

  def total_buyins(table) do
    table.buys
    |> Enum.map(fn({_k, v}) -> v end)
    |> Enum.sum
  end

  def player_balance(table, player_id) do
    {:ok, p} = get_player(table, player_id)
    dpc = dollars_per_chip(table)
    buys = Map.get(table.buys, player_id, 0)
    cashouts = Map.get(table.cashouts, player_id, [])
    remaining = outstanding_chips(table.buyin_chips, buys, cashouts)
    chips_purchased = buys * table.buyin_chips
    chips_returned = Enum.sum(cashouts)
    chip_balance = chips_purchased - chips_returned
    chip_value = chip_balance * dpc
    buyin_total = buys * table.buyin_dollars
    {buys, cashouts, remaining, chip_value, buyin_total}
  end

  def player_views(table) do
    for player <- table.players do
      {buys, cashouts, remaining, chip_value, buyin_total} = balance = player_balance(table, player.id)
      bank = if chip_value < 0 do
        {:owed, -chip_value}
      else
        {:owes, chip_value}
      end
      {player, buys, Enum.sum(cashouts), remaining, bank}
    end
  end

  def balance_sheet(table) do
    total_buys = total_buyins(table)
    total_out = player_views(table)
    |> Enum.reduce(0, fn ({_, _, _, outstanding, _}, acc) -> acc + outstanding end)
    {owed, owes} = player_views(table)
    |> Enum.map(fn {_, _, _, _, bank} -> bank end)
    |> Enum.split_with(fn {owe?, value} -> owe? == :owed end)
    owes = owes |> Enum.reduce(0, fn ({_, value}, acc) -> acc + value end)
    owed = owed |> Enum.reduce(0, fn ({_, value}, acc) -> acc + value end)
    {total_buys, total_out, owes, owed}
  end

  defp dollars_per_chip(table) do
    table.buyin_dollars / table.buyin_chips
  end

  defp outstanding_chips(buyin_chips, buys, cashouts) do
    purchased_chips = buys * buyin_chips
    returned_chips = cashouts |> Enum.sum
    purchased_chips - returned_chips
  end

  defp match_player_id(player_id, {plid, _v}) do
    plid == player_id
  end

end
