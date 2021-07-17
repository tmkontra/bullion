defmodule Bullion.Table.TableManager do
  use GenServer
  import Supervisor.Spec
  alias Bullion.Table.{Game, Player}

  def init(games) when is_map(games) do
    {:ok, games}
  end

  def init(_games), do: {:error, "games must be a map"}

  def handle_call({:start, game_fields}, _from, games) do
    game = Game.new(game_fields)
    {new_game_id, new_games} = add_game(games, game)
    {:reply, {:ok, new_game_id}, new_games}
  end

  def add_game(game, games) do
    new_game_id = length(games) + 1
    new_games = Map.put(games, 1, game)
    {new_game_id, new_games}
  end

  def handle_call({:add_player, game_id, player_name}, _from, games) do
    game = Map.get(games, game_id)
    Game.add_player(game, player_name)
    {:reply, player_name, games}
  end

  def handle_call({:buyin, game_id, player_id}, _from, games) do

  end

end
