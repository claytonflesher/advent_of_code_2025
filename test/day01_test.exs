defmodule AdventOfCode2025.Day01Test do
  use ExUnit.Case
  alias AdventOfCode2025.Day01

  @sample_input """
  L68
  L30
  R48
  L5
  R60
  L55
  L1
  L99
  R14
  L82
  """

  describe "parse_input/1" do
    test "parses sample input correctly" do
      result = Day01.parse_input(@sample_input)
      assert is_list(result)
      assert length(result) == 10
      assert hd(result) == {"L", 68}
      assert Enum.at(result, 2) == {"R", 48}
    end
  end

  describe "part1/1" do
    test "solves part 1 with sample input" do
      result = Day01.part1(@sample_input)
      assert result == 3
    end
  end

  describe "part2/1" do
    test "solves part 2 with sample input" do
      result = Day01.part2(@sample_input)
      assert result == 6
    end
  end
end
