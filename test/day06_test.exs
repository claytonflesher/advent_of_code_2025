defmodule AdventOfCode2025.Day06Test do
  use ExUnit.Case
  alias AdventOfCode2025.Day06

  @sample_input """
  123 328  51 64
   45 64  387 23
    6 98  215 314
  *   +   *   +
  """

  describe "parse_input/1" do
    test "parses sample input correctly" do
      result = Day06.parse_input(@sample_input)
      # Should parse 4 problems: [123,45,6] with *, [328,64,98] with +, etc.
      expected = [
        {[123, 45, 6], "*"},
        {[328, 64, 98], "+"},
        {[51, 387, 215], "*"},
        {[64, 23, 314], "+"}
      ]
      assert result == expected
    end
  end

  describe "part1/1" do
    test "solves part 1 with sample input" do
      result = Day06.part1(@sample_input)
      # Expected: 33210 + 490 + 4243455 + 401 = 4277556
      assert result == 4277556
    end
  end

  describe "part2/1" do
    test "solves part 2 with sample input" do
      result = Day06.part2(@sample_input)
      # Expected: 1058 + 3253600 + 625 + 8544 = 3263827
      # Right-to-left: 321->123, 82->28, 15->51, 46->64 becomes 321, 82, 15, 46
      # Then: 46*32*413 + 15*783*512 + 82*46*89 + 321*54*6
      assert result == 3263827
    end
  end
end
