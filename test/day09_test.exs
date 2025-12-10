defmodule AdventOfCode2025.Day09Test do
  use ExUnit.Case
  alias AdventOfCode2025.Day09

  @sample_input """
  7,1
  11,1
  11,7
  9,7
  9,5
  2,5
  2,3
  7,3
  """

  describe "parse_input/1" do
    test "parses sample input correctly" do
      result = Day09.parse_input(@sample_input)
      assert is_list(result)
      assert length(result) == 8
      assert {7, 1} in result
      assert {11, 1} in result
    end
  end

  describe "part1/1" do
    test "solves part 1 with sample input" do
      result = Day09.part1(@sample_input)
      # Expected result from problem: largest rectangle area is 50
      assert result == 50
    end
  end

  describe "part2/1" do
    test "solves part 2 with sample input" do
      result = Day09.part2(@sample_input)
      # Expected result from problem: largest rectangle area using only red/green tiles is 24
      assert result == 24
    end
  end
end
