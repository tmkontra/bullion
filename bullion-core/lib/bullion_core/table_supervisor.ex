defmodule BullionCore.TableSupervisor do
  use Supervisor

  alias BullionCore.{TableServer, Table}
  alias BullionCore

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

  def start_table(%Table{} = existing_table) do
    Supervisor.start_child(__MODULE__, [existing_table])
  end

  defp table_process_exists?(table) do
    IO.puts "Looking up table"
    case GenServer.whereis(table) do
      nil -> {false, nil}
      pid -> {true, pid}
    end
  end

  defp create_table_process_if_record_exists({running?, pid} = process_already_exists?, table_id) do
    IO.puts "table already running? #{running?}"
    case process_already_exists? do
      {false, nil} ->
        case BullionCore.table_lookup(table_id) do
          nil -> {:error, "Table #{table_id} not found"}
          table ->
            IO.puts "Found table #{table_id}!"
            start_table(table)
        end
      {true, pid} -> {:ok, pid}
    end
  end


  def stop_table(table_id) do
    Supervisor.terminate_child(__MODULE__, table_pid(table_id))
  end

  def view_table(table_id) when is_binary(table_id) do
    with {:ok, table} = table_id
    |> via()
    |> table_process_exists?()
    |> create_table_process_if_record_exists(table_id) do
      TableServer.view_table(table)
    end
  end

  def view_table(table_pid) when is_pid(table_pid) do
    TableServer.view_table(table_pid)
  end

  def add_player(table_id, player_name) do
    table_id
    |> via()
    |> TableServer.add_player(player_name)
  end

  def player_buyin(table_id, player_id) when is_binary(player_id) do
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
