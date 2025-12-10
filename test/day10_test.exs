defmodule AdventOfCode2025.Day10Test do
  use ExUnit.Case
  alias AdventOfCode2025.Day10

  @sample_input """
  [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
  [...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
  [.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
  """

  describe "parse_input/1" do
    test "parses sample input correctly" do
      result = Day10.parse_input(@sample_input)
      assert is_list(result)
      assert length(result) == 3

      # First machine
      first = Enum.at(result, 0)
      assert first.num_lights == 4
      assert first.target == [0, 1, 1, 0]
      assert length(first.buttons) == 6
    end
  end

  describe "part1/1" do
    test "solves part 1 with sample input" do
      result = Day10.part1(@sample_input)
      # 2 + 3 + 2 = 7 from the problem description
      assert result == 7
    end

    test "first machine needs 2 presses" do
      input = "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}"
      assert Day10.part1(input) == 2
    end

    test "second machine needs 3 presses" do
      input = "[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}"
      assert Day10.part1(input) == 3
    end

    test "third machine needs 2 presses" do
      input = "[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"
      assert Day10.part1(input) == 2
    end
  end

  describe "part2/1" do
    test "solves part 2 with sample input" do
      result = Day10.part2(@sample_input)
      # 10 + 12 + 11 = 33 from the problem description
      assert result == 33
    end

    test "first machine joltage needs 10 presses" do
      input = "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}"
      assert Day10.part2(input) == 10
    end

    test "second machine joltage needs 12 presses" do
      input = "[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}"
      assert Day10.part2(input) == 12
    end

    test "third machine joltage needs 11 presses" do
      input = "[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"
      assert Day10.part2(input) == 11
    end
  end
end
