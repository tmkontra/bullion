defmodule BullionWeb.V2Controller do
  use BullionWeb, :controller

  alias BullionCore.{TableSupervisor, TableServer, Table}
  alias Bullion.Repo
  alias Bullion.TableV2

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def start_game(conn, %{"name" => name, "buyin_chips" => buyin_chips, "buyin_dollars" => buyin_dollars}) do
    {buyin_chips, _err} = Integer.parse(buyin_chips)
    {buyin_dollars, _err} = Integer.parse(buyin_dollars)
    {:ok, pid} = TableSupervisor.start_table({name, buyin_chips, buyin_dollars})
    {:ok, table} = pid |> TableServer.view_table()
    table = TableV2.save_new_table(table)
    conn
    |> redirect(to: Routes.v2_path(conn, :view_game, table.id))
  end

  def view_game(conn, %{"game_id" => game_id}) do
    {:ok, table} = TableServer.via(game_id)
    |> TableServer.view_table()
    conn
    |> render("view.html", table: table)
  end

  def add_player(conn, %{"game_id" => game_id, "player" => %{"name" => name}}) do
    table = TableServer.via(game_id)
    {:ok, _plid} = TableServer.add_player(table, name)
    conn
    |> redirect(to: Routes.v2_path(conn, :view_game, game_id))
  end

  @spec add_buyin(Plug.Conn.t(), map) :: Plug.Conn.t()
  def add_buyin(conn, %{"game_id" => game_id, "player_id" => player_id}) do
    table = TableServer.via(game_id)
    {player_id, _err} = Integer.parse(player_id)
    :ok = TableServer.player_buyin(table, player_id)
    conn
    |> redirect(to: Routes.v2_path(conn, :view_game, game_id))
  end

  def cashout_form(conn, %{"game_id" => game_id, "player_id" => player_id}) do
    {:ok, table} = TableServer.via(game_id) |> TableServer.view_table()
    {player_id, _err} = Integer.parse(player_id)
    {:ok, player} = Table.get_player(table, player_id)
    conn
    |> render("cashout.html", table: table, player: player)
  end

  def cashout(conn, %{"game_id" => game_id, "player_id" => player_id, "chip_count" => chip_count}) do
    table = TableServer.via(game_id)
    {player_id, _err} = Integer.parse(player_id)
    {chip_count, _err} = Integer.parse(chip_count)
    :ok = TableServer.player_cashout(table, player_id, chip_count)
    conn
    |> redirect(to: Routes.v2_path(conn, :view_game, game_id))
  end
end
