defmodule BullionCore.TableServer do
  use GenServer, start: {__MODULE__, :start_link, []}, restart: :transient

  alias BullionCore.Table

  def start_link({table_name, buyin_chips, buyin_dollars} = args) when is_binary(table_name) and is_integer(buyin_chips) and is_number(buyin_dollars) do
    table_id = Table.generate_table_id([])
    GenServer.start_link(
      __MODULE__,
      {table_id, table_name, buyin_chips, buyin_dollars},
      name: via(table_id)
    )
  end

  def via(table_id), do: {:via, Registry, {Registry.Table, table_id}}

  def init({table_id, table_name, buyin_chips, buyin_dollars}) do
    {:ok, Table.new(%{id: table_id, name: table_name, buyin_dollars: buyin_dollars, buyin_chips: buyin_chips})}
  end

  def add_player(table, player_name) when is_binary(player_name) do
    GenServer.call(table, {:add_player, player_name})
  end

  def player_buyin(table, player_id) do
    GenServer.call(table, {:buyin, player_id})
  end

  def player_cashout(table, player_id, chip_count) when is_integer(chip_count) do
    GenServer.call({:cashout, {player_id, chip_count}})
  end

  def handle_call({:add_player, player_name}, _from , state) do
    {plid, state} = state
    |> Table.add_player(player_name)
    {:reply, {:ok, plid}, state}
  end

  def handle_call({:buyin, player_id}, _from, state) do
    {_player, state} = state |> Table.buyin(player_id)
    {:reply, :ok, state}
  end

  def handle_call({player_id, chip_count}, _from, state) do
    {_player, state} = state |> Table.cashout(player_id, chip_count)
    {:reply, :ok, state}
  end

end
