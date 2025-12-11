defmodule AdventOfCode2025.Day11 do
  @moduledoc """
  Day 11: Reactor - Find paths through a directed graph of devices.

  Part 1: Count all paths from "you" to "out".
  Part 2: Count paths from "svr" to "out" that visit both "dac" and "fft".
  """

  @doc """
  Solves part 1 of the day 11 puzzle.
  """
  def part1(input) do
    input
    |> parse_input()
    |> solve_part1()
  end

  @doc """
  Solves part 2 of the day 11 puzzle.
  """
  def part2(input) do
    input
    |> parse_input()
    |> solve_part2()
  end

  @doc """
  Parses the input string into a graph (map of device -> list of outputs).
  """
  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.reduce(%{}, fn line, acc ->
      [device, outputs] = String.split(line, ": ")
      output_list = String.split(outputs, " ")
      Map.put(acc, device, output_list)
    end)
  end

  defp solve_part1(graph) do
    # Count all paths from "you" to "out"
    count_paths(graph, "you", "out")
  end

  defp count_paths(_graph, "out", "out"), do: 1
  defp count_paths(graph, current, target) do
    case Map.get(graph, current) do
      nil -> 0  # Dead end, no path to target
      outputs ->
        outputs
        |> Enum.map(&count_paths(graph, &1, target))
        |> Enum.sum()
    end
  end

  defp solve_part2(graph) do
    # Count paths from "svr" to "out" that visit both "dac" and "fft"
    # Use memoization since there can be many paths
    {count, _cache} = count_paths_memo(graph, "svr", "out", MapSet.new(["dac", "fft"]), %{})
    count
  end

  defp count_paths_memo(_graph, "out", "out", required, cache) do
    # Only count if we've visited all required nodes
    if MapSet.size(required) == 0, do: {1, cache}, else: {0, cache}
  end

  defp count_paths_memo(graph, current, target, required, cache) do
    # Remove current from required if it's there
    required = MapSet.delete(required, current)
    cache_key = {current, required}

    case Map.get(cache, cache_key) do
      nil ->
        case Map.get(graph, current) do
          nil -> {0, cache}
          outputs ->
            {sum, new_cache} = Enum.reduce(outputs, {0, cache}, fn next, {acc, c} ->
              {count, c2} = count_paths_memo(graph, next, target, required, c)
              {acc + count, c2}
            end)
            {sum, Map.put(new_cache, cache_key, sum)}
        end
      cached_count ->
        {cached_count, cache}
    end
  end

  @doc """
  Reads the input file for day 11.
  """
  def read_input do
    case File.read("inputs/day11.txt") do
      {:ok, content} -> content
      {:error, _} ->
        raise "Could not read input file for Day 11"
    end
  end
end
