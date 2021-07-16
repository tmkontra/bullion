defmodule Table.Game do
  defstruct ~w[name buyin_dollars buyin_chips players buys cashouts]a

  def new(fields) do
    defaults = %{players: [], buys: %{}, cashouts: %{}}
    fields = Map.merge(fields, defaults)
    struct!(__MODULE__, fields)
  end

  def player_balance(game, player_id) do
    dpc = dollars_per_chip(game)
    out = outstanding_chips(game, player_id)
    dollars = out * dpc
    {out, dollars}
  end

  defp dollars_per_chip(game) do
    game.buyin_dollars / game.buyin_chips
  end

  defp outstanding_chips(game, player_id) do
    {_plid, buys} = game.buys
      |> Enum.find({player_id, 0}, &match_player_id(player_id, &1))
    {_plid, cashouts} = game.cashouts
      |> Enum.find({player_id, [0]}, &match_player_id(player_id, &1))
    purchased_chips = buys * game.buyin_chips
    returned_chips = cashouts |> Enum.sum
    purchased_chips - returned_chips
  end

  defp match_player_id(player_id, {plid, _v}) do
    plid == player_id
  end

end
