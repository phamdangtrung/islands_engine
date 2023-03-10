defmodule IslandsEngine.IslandSet do
  alias IslandsEngine.Coordinate
  alias IslandsEngine.{Island, IslandSet, Coordinate}

  defstruct atoll: :none, dot: :none, l_shape: :none, s_shape: :none, square: :none

  def start_link() do
    Agent.start_link(fn -> initialize_set() end)
  end

  def forested?(_island_set, :none) do
    false
  end

  def forested?(island_set, island_key) do
    island_set
    |> Agent.get(fn state -> Map.get(state, island_key) end)
    |> Island.forested?()
  end

  def to_string(island_set) do
    "%IslandSet{" <> string_body(island_set) <> "}"
  end

  def set_island_coordinates(island_set, island_key, new_coordinates) do
    island = Agent.get(island_set, fn state -> Map.get(state, island_key) end)
    original_coordinates = Agent.get(island, fn state -> state end)
    Island.replace_coordinates(island, new_coordinates)
    Coordinate.set_all_in_island(original_coordinates, :none)
    Coordinate.set_all_in_island(new_coordinates, island_key)
  end

  @spec all_forested?(atom | pid | {atom, any} | {:via, atom, any}) :: boolean
  def all_forested?(island_set) do
    islands = Agent.get(island_set, &(&1))
    Enum.all?(keys(), fn key -> Island.forested?(Map.get(islands, key)) end)
  end

  defp string_body(island_set) do
   Enum.reduce(keys(), "", fn key, acc ->
    island = Agent.get(island_set, &(Map.fetch!(&1, key)))
    acc <> "#{key} => " <> Island.to_string(island) <> "\n"
   end)
  end

  defp initialize_set() do
    Enum.reduce(keys(), %IslandSet{}, fn key, set ->
      {:ok, island} = Island.start_link()
      Map.put(set, key, island)
    end)
  end

  defp keys() do
    %IslandSet{}
    |> Map.from_struct()
    |> Map.keys()
  end
end
