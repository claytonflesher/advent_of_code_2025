defmodule AdventOfCode2025.Day04Test do
  use ExUnit.Case
  alias AdventOfCode2025.Day04

  @sample_input """
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
  """

  describe "parse_input/1" do
    test "parses sample input correctly" do
      result = Day04.parse_input(@sample_input)
      # Should be a map with position keys and character values
      assert is_map(result)
      # Check a few specific positions
      assert result[{0, 2}] == "@"  # First @ in top row
      assert result[{0, 0}] == "."  # First . in top row
      assert result[{1, 0}] == "@"  # First @ in second row
    end
  end

  describe "part1/1" do
    test "solves part 1 with sample input" do
      result = Day04.part1(@sample_input)
      # Expected: 13 accessible rolls based on problem description
      assert result == 13
    end
  end

  describe "part2/1" do
    test "solves part 2 with sample input" do
      result = Day04.part2(@sample_input)
      # Expected: 43 total rolls removed based on problem description
      assert result == 43
    end
  end
end
