defmodule Table do
  alias Table.{Game, Player}
  @moduledoc """
  Documentation for `Table`.
  """

  def add_player(game, name) do
    new_id = length(game.players) + 1
    player = Player.new(new_id, name)
    players = [player | game.players]
    {new_id, %{game | players: players}}
  end

  def buyin(game, player_id) do
    with {:ok, p} <- get_player(game, player_id),
         game <- add_buy(game, player_id)
    do
      {p, game}
    end
  end

  def cashout(game, player_id, chips) do
    with {:ok, p} <- get_player(game, player_id),
         game <- add_cashout(game, player_id, chips)
    do
      {p, game}
    end
  end

  defp add_cashout(game, player_id, chips) do
    existing_cashouts = Map.get(game.cashouts, player_id, [])
    player_cashouts = [chips | existing_cashouts]
    cashouts = Map.put(game.cashouts, player_id, player_cashouts)
    %{game | cashouts: cashouts}
  end

  defp add_buy(game, player_id) do
    existing_buys = Map.get(game.buys, player_id, 0)
    buys = Map.put(game.buys, player_id, existing_buys + 1)
    %{game | buys: buys}
  end

  defp get_player(game, player_id) do
    game.players
      |> Enum.find(fn p -> p.id == player_id end)
      |> case do
        nil -> {:error, "not found"}
        p -> {:ok, p}
      end
  end

  def total_buyins(game) do
    game.buys
    |> Enum.map(fn({_k, v}) -> v end)
    |> Enum.sum
  end

  def balance(game, player_id) do
    {:ok, p} = get_player(game, player_id)
    Table.Game.player_balance(game, player_id)
  end
end
