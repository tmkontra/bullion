defmodule BullionCore do
  @moduledoc """
  Documentation for `BullionCore`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> BullionCore.hello()
      :world

  """
  @table_lookup_fn Application.fetch_env!(:bullion_core, :table_lookup_fn)

  def hello do
    :world
  end

  def table_lookup(table_id, lookup_fn \\ @table_lookup_fn) do
    lookup_fn.(table_id)
  end

end
