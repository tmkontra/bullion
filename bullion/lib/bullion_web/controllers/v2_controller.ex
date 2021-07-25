defmodule BullionWeb.V2Controller do
  use BullionWeb, :controller

  alias BullionCore.{TableSupervisor, Table}

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def start_game(conn, %{"name" => name, "buyin_chips" => buyin_chips, "buyin_dollars" => buyin_dollars}) do
    with {buyin_chips, _err} = Integer.parse(buyin_chips),
         {buyin_dollars, _err} = Integer.parse(buyin_dollars),
         {:ok, pid} = TableSupervisor.start_table({name, buyin_chips, buyin_dollars}),
         {:ok, table} = TableSupervisor.view_table(pid)
    do
      conn
      |> redirect(to: Routes.v2_path(conn, :view_game, table.id))
    end
  end

  def view_game(conn, %{"game_id" => game_id}) do
    {:ok, table} = TableSupervisor.view_table(game_id)
    conn
    |> render("view.html", table: table)
  end

  def add_player(conn, %{"game_id" => game_id, "player" => %{"name" => name}}) do
    {:ok, _plid} = TableSupervisor.add_player(game_id, name)
    conn
    |> redirect(to: Routes.v2_path(conn, :view_game, game_id))
  end

  def add_buyin(conn, %{"game_id" => game_id, "player_id" => player_id}) do
    :ok = TableSupervisor.player_buyin(game_id, player_id)
    conn
    |> redirect(to: Routes.v2_path(conn, :view_game, game_id))
  end

  def cashout_form(conn, %{"game_id" => game_id, "player_id" => player_id}) do
    {:ok, table} = TableSupervisor.view_table(game_id)
    {:ok, player} = Table.get_player(table, player_id)
    conn
    |> render("cashout.html", table: table, player: player)
  end

  def cashout(conn, %{"game_id" => game_id, "player_id" => player_id, "chip_count" => chip_count}) do
    {chip_count, _err} = Integer.parse(chip_count)
    :ok = TableSupervisor.player_cashout(game_id, player_id, chip_count)
    conn
    |> redirect(to: Routes.v2_path(conn, :view_game, game_id))
  end
end
