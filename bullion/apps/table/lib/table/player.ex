defmodule Table.Player do
  defstruct ~w[id name]a

  def new(id, name) do
    %__MODULE__{id: id, name: name}
  end
end
