defmodule BullionCore.TableSupervisor do
  use Supervisor

  alias BullionCore.TableServer

  def start_link(_options) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Supervisor.init([TableServer], strategy: :simple_one_for_one)
  end

  def start_table({_table_name, _buyin_chips, _buyin_dollars} = args) do
    Supervisor.start_child(__MODULE__, [args])
  end

  def stop_table(table_id) do
    Supervisor.terminate_child(__MODULE__, table_pid(table_id))
  end

  defp table_pid(table_id) do
    table_id
    |> TableServer.via()
    |> GenServer.whereis()
  end

end
