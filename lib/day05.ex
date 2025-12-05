defmodule AdventOfCode2025.Day05 do
  @moduledoc """
  --- Day 5: Cafeteria ---
  As the forklifts break through the wall, the Elves are delighted to discover that there was a cafeteria on the other side after all.

  You can hear a commotion coming from the kitchen. "At this rate, we won't have any time left to put the wreaths up in the dining hall!" Resolute in your quest, you investigate.

  "If only we hadn't switched to the new inventory management system right before Christmas!" another Elf exclaims. You ask what's going on.

  The Elves in the kitchen explain the situation: because of their complicated new inventory management system, they can't figure out which of their ingredients are fresh and which are spoiled. When you ask how it works, they give you a copy of their database (your puzzle input).

  The database operates on ingredient IDs. It consists of a list of fresh ingredient ID ranges, a blank line, and a list of available ingredient IDs. For example:

  3-5
  10-14
  16-20
  12-18

  1
  5
  8
  11
  17
  32
  The fresh ID ranges are inclusive: the range 3-5 means that ingredient IDs 3, 4, and 5 are all fresh. The ranges can also overlap; an ingredient ID is fresh if it is in any range.

  The Elves are trying to determine which of the available ingredient IDs are fresh. In this example, this is done as follows:

  Ingredient ID 1 is spoiled because it does not fall into any range.
  Ingredient ID 5 is fresh because it falls into range 3-5.
  Ingredient ID 8 is spoiled.
  Ingredient ID 11 is fresh because it falls into range 10-14.
  Ingredient ID 17 is fresh because it falls into range 16-20 as well as range 12-18.
  Ingredient ID 32 is spoiled.
  So, in this example, 3 of the available ingredient IDs are fresh.

  Process the database file from the new inventory management system. How many of the available ingredient IDs are fresh?

  --- Part Two ---
  The Elves start bringing their spoiled inventory to the trash chute at the back of the kitchen.

  So that they can stop bugging you when they get new inventory, the Elves would like to know all of the IDs that the fresh ingredient ID ranges consider to be fresh. An ingredient ID is still considered fresh if it is in any range.

  Now, the second section of the database (the available ingredient IDs) is irrelevant. Here are the fresh ingredient ID ranges from the above example:

  3-5
  10-14
  16-20
  12-18
  The ingredient IDs that these ranges consider to be fresh are 3, 4, 5, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, and 20. So, in this example, the fresh ingredient ID ranges consider a total of 14 ingredient IDs to be fresh.

  Process the database file again. How many ingredient IDs are considered to be fresh according to the fresh ingredient ID ranges?
  """

  @doc """
  Solves part 1 of the day 5 puzzle.
  """
  def part1(input) do
    input
    |> parse_input()
    |> solve_part1()
  end

  @doc """
  Solves part 2 of the day 5 puzzle.
  """
  def part2(input) do
    input
    |> parse_input()
    |> solve_part2()
  end

  @doc """
  Parses the input string into a data structure.
  """
  def parse_input(input) do
    [ranges_section, ids_section] = input
    |> String.trim()
    |> String.split("\n\n", parts: 2)

    ranges = ranges_section
    |> String.split("\n")
    |> Enum.map(&parse_range/1)

    ingredient_ids = ids_section
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)

    {ranges, ingredient_ids}
  end

  # Parse a range string like "3-5" into {3, 5}
  defp parse_range(range_str) do
    [start_str, end_str] = String.split(range_str, "-")
    {String.to_integer(start_str), String.to_integer(end_str)}
  end

  defp solve_part1({ranges, ingredient_ids}) do
    ingredient_ids
    |> Enum.count(fn id -> is_fresh?(id, ranges) end)
  end

  # Check if an ingredient ID is fresh (falls within any range)
  defp is_fresh?(id, ranges) do
    Enum.any?(ranges, fn {start, finish} -> id >= start and id <= finish end)
  end

  defp solve_part2({ranges, _ingredient_ids}) do
    ranges
    |> merge_overlapping_ranges()
    |> Enum.map(fn {start, finish} -> finish - start + 1 end)
    |> Enum.sum()
  end

  # Merge overlapping ranges to avoid double counting
  defp merge_overlapping_ranges(ranges) do
    ranges
    |> Enum.sort()
    |> Enum.reduce([], &merge_range/2)
  end

  # Merge a range with the accumulated list of non-overlapping ranges
  defp merge_range({start, finish}, []) do
    [{start, finish}]
  end

  defp merge_range({start, finish}, [{last_start, last_finish} | rest] = acc) do
    if start <= last_finish + 1 do
      # Ranges overlap or are adjacent, merge them
      [{last_start, max(finish, last_finish)} | rest]
    else
      # No overlap, add as new range
      [{start, finish} | acc]
    end
  end

  @doc """
  Convenience function to solve part 1 with input from file.
  """
  def solve_part1 do
    read_input() |> part1()
  end

  @doc """
  Convenience function to solve part 2 with input from file.
  """
  def solve_part2 do
    read_input() |> part2()
  end

  @doc """
  Reads the input file for day 5.
  """
  def read_input do
    case File.read("inputs/day05.txt") do
      {:ok, content} -> content
      {:error, _} ->
        raise "Could not read input file for Day 5"
    end
  end
end
