defmodule BullionCore.Table do
  defstruct ~w[id name buyin_dollars buyin_chips players buys cashouts]a

  alias BullionCore.Player

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

  defp get_player(table, player_id) do
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
    out = outstanding_chips(table, player_id)
    dollars = out * dpc
    {out, dollars}
  end

  defp dollars_per_chip(table) do
    table.buyin_dollars / table.buyin_chips
  end

  defp outstanding_chips(table, player_id) do
    {_plid, buys} = table.buys
      |> Enum.find({player_id, 0}, &match_player_id(player_id, &1))
    {_plid, cashouts} = table.cashouts
      |> Enum.find({player_id, [0]}, &match_player_id(player_id, &1))
    purchased_chips = buys * table.buyin_chips
    returned_chips = cashouts |> Enum.sum
    purchased_chips - returned_chips
  end

  defp match_player_id(player_id, {plid, _v}) do
    plid == player_id
  end

end
