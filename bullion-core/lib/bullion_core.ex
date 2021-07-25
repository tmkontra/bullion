defmodule BullionCore do
  @moduledoc """
  Documentation for `BullionCore`.
  """

  alias BullionCore.Table

  @table_lookup_fn Application.fetch_env!(:bullion_core, :table_lookup_fn)
  @save_new_table_fn Application.fetch_env!(:bullion_core, :save_new_table_fn)
  @save_new_player_fn Application.fetch_env!(:bullion_core, :save_new_player_fn)
  @save_buyin_fn Application.fetch_env!(:bullion_core, :save_buyin_fn)
  @save_cashout_fn Application.fetch_env!(:bullion_core, :save_cashout_fn)

  def hello do
    :world
  end

  @spec table_lookup(binary(), (binary -> Table | nil)) :: Table | nil
  def table_lookup(table_id, lookup_fn \\ @table_lookup_fn) when is_binary(table_id) do
    lookup_fn.(table_id)
  end

  def save_new_table(%Table{} = table, save_fn \\ @save_new_table_fn) do
    save_fn.(table)
  end

  @spec save_player(any, any, (any, any -> any)) :: any
  def save_player(table, player, save_fn \\ @save_new_player_fn) do
    save_fn.(table, player)
  end

  def save_buyin(table_id, player_id, save_fn \\ @save_buyin_fn) do
    save_fn.(to_string(table_id), to_string(player_id))
  end

  def save_cashout(table_id, player_id, chip_count, save_fn \\ @save_cashout_fn) do
    save_fn.(table_id, player_id, chip_count)
  end

end
