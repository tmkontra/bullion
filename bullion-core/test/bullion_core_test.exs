defmodule BullionCoreTest do
  use ExUnit.Case
  doctest BullionCore

  test "greets the world" do
    assert BullionCore.hello() == :world
  end
end
