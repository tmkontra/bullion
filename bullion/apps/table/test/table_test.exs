defmodule TableTest do
  use ExUnit.Case
  doctest Table

  alias Table

  test "set up a game" do
    g = Table.Game.new(%{name: "my great game", buyin_dollars: 20, buyin_chips: 100})
    assert length(g.players) == 0
    {_plid, g} = Table.add_player(g, "Tyler")
    assert length(g.players) == 1
    [p] = g.players
    assert p.name == "Tyler"
  end

  test "buyin increments counter" do
    {plid, g} = Table.Game.new(%{name: "my great game", buyin_dollars: 20, buyin_chips: 100})
      |> Table.add_player("Tyler")
    assert(Table.total_buyins(g) == 0)
    {_player, g} = Table.buyin(g, plid)
    assert(Table.total_buyins(g) == 1)
    {player_chips, player_value} = Table.balance(g, plid)
    assert(player_chips == g.buyin_chips)
    assert(player_value == g.buyin_dollars)
  end

  test "cashouts should update balance" do
    {plid, g} = Table.Game.new(%{name: "my great game", buyin_dollars: 20, buyin_chips: 100})
      |> Table.add_player("Tyler")
    {_player, g} = Table.buyin(g, plid)
    {_player, g} = Table.cashout(g, plid, 22)
    {player_chips, player_value} = Table.balance(g, plid)
    assert(player_chips == g.buyin_chips - 22)
    assert(player_value < g.buyin_dollars)
  end
end
