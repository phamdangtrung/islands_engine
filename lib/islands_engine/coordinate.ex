defmodule IslandsEngine.Coordinate do
  defstruct in_island: :none, guessed?: false

  alias IslandsEngine.Coordinate

  @spec start_link :: {:error, any} | {:ok, pid}
  def start_link() do
    Agent.start_link(fn -> %Coordinate{} end)
  end

  def guessed?(coordinate) do
    Agent.get(coordinate, fn state -> state.guessed? end)
  end

  def island(coordinate) do
    Agent.get(coordinate, fn state -> state.in_island end)
  end

  def in_island?(coordinate) do
    case island(coordinate) do
      :none -> false
      _     -> true
    end
  end

  def hit?(coordinate) do
    in_island?(coordinate) && guessed?(coordinate)
  end

  def guess(coordinate) do
    Agent.update(coordinate, &(Map.put(&1, :guessed?, true)))
  end

  def set_in_island(coordinate, value) when is_atom(value) do
    Agent.update(coordinate, &(Map.put(&1, :in_island, value)))
  end

  def set_all_in_island(coordinates, value) when is_list(coordinates) and is_atom(value) do
    Enum.each(coordinates, fn coord -> set_in_island(coord, value) end)
  end

  def to_string(coordinate) do
    "(in_island: #{island(coordinate)}, guessed: #{guessed?(coordinate)})"
  end
end
