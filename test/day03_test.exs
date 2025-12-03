defmodule AdventOfCode2025.Day03Test do
  use ExUnit.Case
  alias AdventOfCode2025.Day03

  @sample_input """
  987654321111111
  811111111111119
  234234234234278
  818181911112111
  """

  describe "parse_input/1" do
    test "parses sample input correctly" do
      result = Day03.parse_input(@sample_input)
      expected = [
        [9, 8, 7, 6, 5, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1],
        [8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9],
        [2, 3, 4, 2, 3, 4, 2, 3, 4, 2, 3, 4, 2, 7, 8],
        [8, 1, 8, 1, 8, 1, 9, 1, 1, 1, 1, 2, 1, 1, 1]
      ]
      assert result == expected
    end
  end

  describe "part1/1" do
    test "solves part 1 with sample input" do
      result = Day03.part1(@sample_input)
      # Expected: 98 + 89 + 78 + 92 = 357
      assert result == 357
    end
  end

  describe "part2/1" do
    test "solves part 2 with sample input" do
      result = Day03.part2(@sample_input)
      # Expected: 987654321111 + 811111111119 + 434234234278 + 888911112111 = 3121910778619
      assert result == 3121910778619
    end
  end
end
