defmodule AdventOfCode2025.Day02Test do
  use ExUnit.Case
  alias AdventOfCode2025.Day02

  @sample_input """
  11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124
  """

  describe "parse_input/1" do
    test "parses sample input correctly" do
      result = Day02.parse_input(@sample_input)
      assert is_list(result)
      assert length(result) == 11
      assert hd(result) == {11, 22}
      assert Enum.at(result, 1) == {95, 115}
    end
  end

  describe "invalid ID detection" do
    test "identifies invalid IDs correctly" do
      # Test some specific examples from the problem
      assert Day02.invalid_id?(11) == true   # 1 twice
      assert Day02.invalid_id?(22) == true   # 2 twice
      assert Day02.invalid_id?(55) == true   # 5 twice
      assert Day02.invalid_id?(99) == true   # 9 twice
      assert Day02.invalid_id?(1010) == true # 10 twice
      assert Day02.invalid_id?(6464) == true # 64 twice
      assert Day02.invalid_id?(123123) == true # 123 twice

      # Test some invalid cases
      assert Day02.invalid_id?(12) == false  # Not repeated
      assert Day02.invalid_id?(123) == false # Odd length
      assert Day02.invalid_id?(1234) == false # 12 != 34
      assert Day02.invalid_id?(0101) == false # Has leading zeros (wouldn't be valid ID anyway)
    end
  end

  describe "invalid ID detection part 2" do
    test "identifies invalid IDs correctly for part 2" do
      # Test examples from part 2
      assert Day02.invalid_id_part2?(12341234) == true  # 1234 two times
      assert Day02.invalid_id_part2?(123123123) == true # 123 three times
      assert Day02.invalid_id_part2?(1212121212) == true # 12 five times
      assert Day02.invalid_id_part2?(1111111) == true   # 1 seven times
      assert Day02.invalid_id_part2?(111) == true       # 1 three times
      assert Day02.invalid_id_part2?(999) == true       # 9 three times
      assert Day02.invalid_id_part2?(565656) == true    # 56 three times
      assert Day02.invalid_id_part2?(824824824) == true # 824 three times
      assert Day02.invalid_id_part2?(2121212121) == true # 21 five times

      # Still works for part 1 cases
      assert Day02.invalid_id_part2?(11) == true
      assert Day02.invalid_id_part2?(22) == true
      assert Day02.invalid_id_part2?(6464) == true

      # Test some invalid cases
      assert Day02.invalid_id_part2?(12) == false  # Not repeated
      assert Day02.invalid_id_part2?(123) == false # Single occurrence
      assert Day02.invalid_id_part2?(1234) == false # No repetition
    end
  end

  describe "part1/1" do
    test "solves part 1 with sample input" do
      result = Day02.part1(@sample_input)
      assert result == 1227775554
    end
  end

  describe "part2/1" do
    test "solves part 2 with sample input" do
      result = Day02.part2(@sample_input)
      assert result == 4174379265
    end
  end
end
