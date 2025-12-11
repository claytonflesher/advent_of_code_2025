defmodule AdventOfCode2025.Day11Test do
  use ExUnit.Case
  alias AdventOfCode2025.Day11

  @sample_input """
  aaa: you hhh
  you: bbb ccc
  bbb: ddd eee
  ccc: ddd eee fff
  ddd: ggg
  eee: out
  fff: out
  ggg: out
  hhh: ccc fff iii
  iii: out
  """

  @sample_input2 """
  svr: aaa bbb
  aaa: fft
  fft: ccc
  bbb: tty
  tty: ccc
  ccc: ddd eee
  ddd: hub
  hub: fff
  eee: dac
  dac: fff
  fff: ggg hhh
  ggg: out
  hhh: out
  """

  describe "parse_input/1" do
    test "parses sample input correctly" do
      result = Day11.parse_input(@sample_input)
      assert is_map(result)
      assert result["you"] == ["bbb", "ccc"]
      assert result["bbb"] == ["ddd", "eee"]
    end
  end

  describe "part1/1" do
    test "solves part 1 with sample input" do
      result = Day11.part1(@sample_input)
      assert result == 5
    end
  end

  describe "part2/1" do
    test "solves part 2 with sample input" do
      result = Day11.part2(@sample_input2)
      assert result == 2
    end
  end
end
