defmodule AdventOfCode2025.Day07Test do
  use ExUnit.Case
  alias AdventOfCode2025.Day07

  @sample_input """
.......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
...............
"""

  describe "parse_input/1" do
    test "parses sample input correctly" do
      {grid, start_pos, height, width} = Day07.parse_input(@sample_input)

      assert start_pos == {0, 7}
      assert height == 16
      assert width == 15
      assert Map.get(grid, {0, 7}) == "S"
      assert Map.get(grid, {2, 7}) == "^"
    end
  end

  describe "part1/1" do
    test "solves part 1 with sample input" do
      result = Day07.part1(@sample_input)
      # Based on the problem description, this should be 21 splits
      assert result == 21
    end
  end

  describe "part2/1" do
    test "solves part 2 with sample input" do
      result = Day07.part2(@sample_input)
      # Based on the problem description, this should be 40 timelines
      assert result == 40
    end
  end
end
