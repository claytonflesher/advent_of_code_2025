defmodule AdventOfCode2025.Day05Test do
  use ExUnit.Case
  alias AdventOfCode2025.Day05

  @sample_input """
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
  """

  describe "parse_input/1" do
    test "parses sample input correctly" do
      result = Day05.parse_input(@sample_input)
      {ranges, ingredient_ids} = result

      # Check ranges
      assert ranges == [{3, 5}, {10, 14}, {16, 20}, {12, 18}]

      # Check ingredient IDs
      assert ingredient_ids == [1, 5, 8, 11, 17, 32]
    end
  end

  describe "part1/1" do
    test "solves part 1 with sample input" do
      result = Day05.part1(@sample_input)
      # Expected: 3 fresh ingredients (5, 11, 17) based on problem description
      assert result == 3
    end
  end

  describe "part2/1" do
    test "solves part 2 with sample input" do
      result = Day05.part2(@sample_input)
      # Expected: 14 total fresh ingredient IDs (3,4,5,10,11,12,13,14,15,16,17,18,19,20)
      assert result == 14
    end
  end
end
