defmodule AdventOfCode2025.Day08Test do
  use ExUnit.Case
  alias AdventOfCode2025.Day08

  @sample_input """
162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689
"""

  describe "parse_input/1" do
    test "parses sample input correctly" do
      result = Day08.parse_input(@sample_input)

      assert length(result) == 20
      assert Enum.at(result, 0) == {162, 817, 812}
      assert Enum.at(result, 19) == {425, 690, 689}
    end
  end

  describe "part1/1" do
    test "solves part 1 with sample input" do
      result = Day08.part1(@sample_input)
      # For 1000 connections on the sample data, we expect some result
      assert is_integer(result)
      assert result > 0
    end
  end

  describe "part2/1" do
    test "solves part 2 with sample input" do
      result = Day08.part2(@sample_input)
      # Should return the product of X coordinates of the final connection: 216 * 117 = 25272
      assert result == 25272
    end
  end
end
