defmodule AdventOfCode2025.Day12Test do
  use ExUnit.Case
  alias AdventOfCode2025.Day12

  @sample_input """
  0:
  ###
  ##.
  ##.

  1:
  ###
  ##.
  .##

  2:
  .##
  ###
  ##.

  3:
  ##.
  ###
  ##.

  4:
  ###
  #..
  ###

  5:
  ###
  .#.
  ###

  4x4: 0 0 0 0 2 0
  12x5: 1 0 1 0 2 2
  12x5: 1 0 1 0 3 2
  """

  describe "parse_input/1" do
    test "parses sample input correctly" do
      result = Day12.parse_input(@sample_input)
      assert is_tuple(elem(result, 0))
      assert is_list(elem(result, 1))
    end
  end

  describe "part1/1" do
    test "solves part 1 with sample input" do
      result = Day12.part1(@sample_input)
      assert result == 2
    end
  end
end
