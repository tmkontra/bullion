defmodule BullionCore.TableSupervisor do
  use Supervisor

  alias BullionCore.TableServer

  def start_link(_options) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Supervisor.init([TableServer], strategy: :simple_one_for_one)
  end

  defp via(table_id) do
    TableServer.via(table_id)
  end

  def start_table({_table_name, _buyin_chips, _buyin_dollars} = args) do
    Supervisor.start_child(__MODULE__, [args])
  end

  defp table_process_exists?(table) do
    case Registry.lookup(Registry.Table, table) do
      [] -> false
      _ -> true
    end
  end

  def stop_table(table_id) do
    Supervisor.terminate_child(__MODULE__, table_pid(table_id))
  end

  def view_table(table_id) when is_binary(table_id) do
    table_id
    |> via()
    |> TableServer.view_table()
  end

  def view_table(table_pid) when is_pid(table_pid) do
    TableServer.view_table(table_pid)
  end

  def add_player(table_id, player_name) do
    table_id
    |> via()
    |> TableServer.add_player(player_name)
  end

  def player_buyin(table_id, player_id) do
    table_id
    |> via()
    |> TableServer.player_buyin(player_id)
  end

  def player_cashout(table_id, player_id, chip_count) do
    table_id
    |> via()
    |> TableServer.player_cashout(player_id, chip_count)
  end

  defp table_pid(table_id) do
    table_id
    |> via()
    |> GenServer.whereis()
  end

end
