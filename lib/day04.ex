defmodule AdventOfCode2025.Day04 do
  @moduledoc """
  --- Day 4: Printing Department ---
  You ride the escalator down to the printing department. They're clearly getting ready for Christmas; they have lots of large rolls of paper everywhere, and there's even a massive printer in the corner (to handle the really big print jobs).

  Decorating here will be easy: they can make their own decorations. What you really need is a way to get further into the North Pole base while the elevators are offline.

  "Actually, maybe we can help with that," one of the Elves replies when you ask for help. "We're pretty sure there's a cafeteria on the other side of the back wall. If we could break through the wall, you'd be able to keep moving. It's too bad all of our forklifts are so busy moving those big rolls of paper around."

  If you can optimize the work the forklifts are doing, maybe they would have time to spare to break through the wall.

  The rolls of paper (@) are arranged on a large grid; the Elves even have a helpful diagram (your puzzle input) indicating where everything is located.

  For example:

  ..@@.@@@@.
  @@@.@.@.@@
  @@@@@.@.@@
  @.@@@@..@.
  @@.@@@@.@@
  .@@@@@@@.@
  .@.@.@.@@@
  @.@@@.@@@@
  .@@@@@@@@.
  @.@.@@@.@.
  The forklifts can only access a roll of paper if there are fewer than four rolls of paper in the eight adjacent positions. If you can figure out which rolls of paper the forklifts can access, they'll spend less time looking and more time breaking down the wall to the cafeteria.

  In this example, there are 13 rolls of paper that can be accessed by a forklift (marked with x):

  ..xx.xx@x.
  x@@.@.@.@@
  @@@@@.x.@@
  @.@@@@..@.
  x@.@@@@.@x
  .@@@@@@@.@
  .@.@.@.@@@
  x.@@@.@@@@
  .@@@@@@@@.
  x.x.@@@.x.
  Consider your complete diagram of the paper roll locations. How many rolls of paper can be accessed by a forklift?

  --- Part Two ---
  Now, the Elves just need help accessing as much of the paper as they can.

  Once a roll of paper can be accessed by a forklift, it can be removed. Once a roll of paper is removed, the forklifts might be able to access more rolls of paper, which they might also be able to remove. How many total rolls of paper could the Elves remove if they keep repeating this process?

  Starting with the same example as above, here is one way you could remove as many rolls of paper as possible, using highlighted @ to indicate that a roll of paper is about to be removed, and using x to indicate that a roll of paper was just removed:

  Initial state:
  ..@@.@@@@.
  @@@.@.@.@@
  @@@@@.@.@@
  @.@@@@..@.
  @@.@@@@.@@
  .@@@@@@@.@
  .@.@.@.@@@
  @.@@@.@@@@
  .@@@@@@@@.
  @.@.@@@.@.

  Remove 13 rolls of paper:
  ..xx.xx@x.
  x@@.@.@.@@
  @@@@@.x.@@
  @.@@@@..@.
  x@.@@@@.@x
  .@@@@@@@.@
  .@.@.@.@@@
  x.@@@.@@@@
  .@@@@@@@@.
  x.x.@@@.x.

  Remove 12 rolls of paper:
  .......x..
  .@@.x.x.@x
  x@@@@...@@
  x.@@@@..x.
  .@.@@@@.x.
  .x@@@@@@.x
  .x.@.@.@@@
  ..@@@.@@@@
  .x@@@@@@@.
  ....@@@...

  Remove 7 rolls of paper:
  ..........
  .x@.....x.
  .@@@@...xx
  ..@@@@....
  .x.@@@@...
  ..@@@@@@..
  ...@.@.@@x
  ..@@@.@@@@
  ..x@@@@@@.
  ....@@@...

  Remove 5 rolls of paper:
  ..........
  ..x.......
  .x@@@.....
  ..@@@@....
  ...@@@@...
  ..x@@@@@..
  ...@.@.@@.
  ..x@@.@@@x
  ...@@@@@@.
  ....@@@...

  Remove 2 rolls of paper:
  ..........
  ..........
  ..x@@.....
  ..@@@@....
  ...@@@@...
  ...@@@@@..
  ...@.@.@@.
  ...@@.@@@.
  ...@@@@@x.
  ....@@@...

  Remove 1 roll of paper:
  ..........
  ..........
  ...@@.....
  ..x@@@....
  ...@@@@...
  ...@@@@@..
  ...@.@.@@.
  ...@@.@@@.
  ...@@@@@..
  ....@@@...

  Remove 1 roll of paper:
  ..........
  ..........
  ...x@.....
  ...@@@....
  ...@@@@...
  ...@@@@@..
  ...@.@.@@.
  ...@@.@@@.
  ...@@@@@..
  ....@@@...

  Remove 1 roll of paper:
  ..........
  ..........
  ....x.....
  ...@@@....
  ...@@@@...
  ...@@@@@..
  ...@.@.@@.
  ...@@.@@@.
  ...@@@@@..
  ....@@@...

  Remove 1 roll of paper:
  ..........
  ..........
  ..........
  ...x@@....
  ...@@@@...
  ...@@@@@..
  ...@.@.@@.
  ...@@.@@@.
  ...@@@@@..
  ....@@@...
  Stop once no more rolls of paper are accessible by a forklift. In this example, a total of 43 rolls of paper can be removed.

  Start with your original diagram. How many rolls of paper in total can be removed by the Elves and their forklifts?
  """

  @doc """
  Solves part 1 of the day 4 puzzle.
  """
  def part1(input) do
    input
    |> parse_input()
    |> solve_part1()
  end

  @doc """
  Solves part 2 of the day 4 puzzle.
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
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, row} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {char, col} -> {{row, col}, char} end)
    end)
    |> Enum.into(%{})
  end

  defp solve_part1(grid) do
    grid
    |> Enum.filter(fn {_pos, char} -> char == "@" end)
    |> Enum.count(fn {pos, _char} -> accessible_by_forklift?(grid, pos) end)
  end

  # Check if a paper roll is accessible by forklift (< 4 adjacent rolls)
  defp accessible_by_forklift?(grid, {row, col}) do
    adjacent_count = count_adjacent_rolls(grid, {row, col})
    adjacent_count < 4
  end

  # Count paper rolls in the 8 adjacent positions
  defp count_adjacent_rolls(grid, {row, col}) do
    adjacent_positions(row, col)
    |> Enum.count(fn pos -> Map.get(grid, pos) == "@" end)
  end

  # Get all 8 adjacent positions
  defp adjacent_positions(row, col) do
    [
      {row - 1, col - 1}, {row - 1, col}, {row - 1, col + 1},
      {row, col - 1},                     {row, col + 1},
      {row + 1, col - 1}, {row + 1, col}, {row + 1, col + 1}
    ]
  end

  defp solve_part2(grid) do
    simulate_removal(grid, 0)
  end

  # Simulate iterative removal of accessible rolls
  defp simulate_removal(grid, total_removed) do
    accessible_rolls = find_accessible_rolls(grid)

    if Enum.empty?(accessible_rolls) do
      total_removed
    else
      # Remove accessible rolls from the grid
      updated_grid = remove_rolls(grid, accessible_rolls)
      simulate_removal(updated_grid, total_removed + length(accessible_rolls))
    end
  end

  # Find all rolls that are accessible by forklifts
  defp find_accessible_rolls(grid) do
    grid
    |> Enum.filter(fn {_pos, char} -> char == "@" end)
    |> Enum.filter(fn {pos, _char} -> accessible_by_forklift?(grid, pos) end)
    |> Enum.map(fn {pos, _char} -> pos end)
  end

  # Remove rolls from the grid by setting their positions to "."
  defp remove_rolls(grid, positions) do
    Enum.reduce(positions, grid, fn pos, acc_grid ->
      Map.put(acc_grid, pos, ".")
    end)
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
  Reads the input file for day 4.
  """
  def read_input do
    case File.read("inputs/day04.txt") do
      {:ok, content} -> content
      {:error, _} ->
        raise "Could not read input file for Day 4"
    end
  end
end
