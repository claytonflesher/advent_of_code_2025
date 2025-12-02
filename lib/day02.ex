defmodule AdventOfCode2025.Day02 do
  @moduledoc """
  --- Day 2: Gift Shop ---
  You get inside and take the elevator to its only other stop: the gift shop. "Thank you for visiting the North Pole!" gleefully exclaims a nearby sign. You aren't sure who is even allowed to visit the North Pole, but you know you can access the lobby through here, and from there you can access the rest of the North Pole base.

  As you make your way through the surprisingly extensive selection, one of the clerks recognizes you and asks for your help.

  As it turns out, one of the younger Elves was playing on a gift shop computer and managed to add a whole bunch of invalid product IDs to their gift shop database! Surely, it would be no trouble for you to identify the invalid product IDs for them, right?

  They've even checked most of the product ID ranges already; they only have a few product ID ranges (your puzzle input) that you'll need to check. For example:

  11-22,95-115,998-1012,1188511880-1188511890,222220-222224,
  1698522-1698528,446443-446449,38593856-38593862,565653-565659,
  824824821-824824827,2121212118-2121212124
  (The ID ranges are wrapped here for legibility; in your input, they appear on a single long line.)

  The ranges are separated by commas (,); each range gives its first ID and last ID separated by a dash (-).

  Since the young Elf was just doing silly patterns, you can find the invalid IDs by looking for any ID which is made only of some sequence of digits repeated twice. So, 55 (5 twice), 6464 (64 twice), and 123123 (123 twice) would all be invalid IDs.

  None of the numbers have leading zeroes; 0101 isn't an ID at all. (101 is a valid ID that you would ignore.)

  Your job is to find all of the invalid IDs that appear in the given ranges. In the above example:

  11-22 has two invalid IDs, 11 and 22.
  95-115 has one invalid ID, 99.
  998-1012 has one invalid ID, 1010.
  1188511880-1188511890 has one invalid ID, 1188511885.
  222220-222224 has one invalid ID, 222222.
  1698522-1698528 contains no invalid IDs.
  446443-446449 has one invalid ID, 446446.
  38593856-38593862 has one invalid ID, 38593859.
  The rest of the ranges contain no invalid IDs.
  Adding up all the invalid IDs in this example produces 1227775554.

  What do you get if you add up all of the invalid IDs?

  --- Part Two ---
  The clerk quickly discovers that there are still invalid IDs in the ranges in your list. Maybe the young Elf was doing other silly patterns as well?

  Now, an ID is invalid if it is made only of some sequence of digits repeated at least twice. So, 12341234 (1234 two times), 123123123 (123 three times), 1212121212 (12 five times), and 1111111 (1 seven times) are all invalid IDs.

  From the same example as before:

  11-22 still has two invalid IDs, 11 and 22.
  95-115 now has two invalid IDs, 99 and 111.
  998-1012 now has two invalid IDs, 999 and 1010.
  1188511880-1188511890 still has one invalid ID, 1188511885.
  222220-222224 still has one invalid ID, 222222.
  1698522-1698528 still contains no invalid IDs.
  446443-446449 still has one invalid ID, 446446.
  38593856-38593862 still has one invalid ID, 38593859.
  565653-565659 now has one invalid ID, 565656.
  824824821-824824827 now has one invalid ID, 824824824.
  2121212118-2121212124 now has one invalid ID, 2121212121.
  Adding up all the invalid IDs in this example produces 4174379265.

  What do you get if you add up all of the invalid IDs using these new rules?
  """

  @doc """
  Solves part 1 of the day 2 puzzle.
  """
  def part1(input) do
    input
    |> parse_input()
    |> solve_part1()
  end

  @doc """
  Solves part 2 of the day 2 puzzle.
  """
  def part2(input) do
    input
    |> parse_input()
    |> solve_part2()
  end

  @doc """
  Parses the input string into a list of ranges.
  """
  def parse_input(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&parse_range/1)
  end

  defp parse_range(range_str) do
    [start_str, end_str] = String.split(range_str, "-")
    {String.to_integer(start_str), String.to_integer(end_str)}
  end

  defp solve_part1(ranges) do
    ranges
    |> Enum.flat_map(&find_invalid_ids_in_range/1)
    |> Enum.sum()
  end

  defp find_invalid_ids_in_range({start_id, end_id}) do
    start_id..end_id
    |> Enum.filter(&invalid_id?/1)
  end

  defp find_invalid_ids_in_range_part2({start_id, end_id}) do
    start_id..end_id
    |> Enum.filter(&invalid_id_part2?/1)
  end

  def invalid_id?(id) do
    id_str = Integer.to_string(id)
    length = String.length(id_str)

    # Must be even length to be made of repeated digits
    if rem(length, 2) == 0 do
      half_length = div(length, 2)
      first_half = String.slice(id_str, 0, half_length)
      second_half = String.slice(id_str, half_length, half_length)

      first_half == second_half and first_half != "0"
    else
      false
    end
  end

  def invalid_id_part2?(id) do
    id_str = Integer.to_string(id)
    length = String.length(id_str)

    # Need at least length 2 for any repetition
    if length < 2 do
      false
    else
      # Try all possible pattern lengths (from 1 to length/2)
      # The pattern must repeat at least twice
      max_pattern_length = div(length, 2)

      1..max_pattern_length
      |> Enum.any?(fn pattern_length ->
        if rem(length, pattern_length) == 0 do
          repetitions = div(length, pattern_length)
          if repetitions >= 2 do
            pattern = String.slice(id_str, 0, pattern_length)
            # Check if the entire string is this pattern repeated
            repeated_pattern = String.duplicate(pattern, repetitions)
            repeated_pattern == id_str and pattern != "0"
          else
            false
          end
        else
          false
        end
      end)
    end
  end

  defp solve_part2(ranges) do
    ranges
    |> Enum.flat_map(&find_invalid_ids_in_range_part2/1)
    |> Enum.sum()
  end

  @doc """
  Reads the input file for day 2.
  """
  def read_input do
    case File.read("inputs/day02.txt") do
      {:ok, content} -> content
      {:error, _} ->
        raise "Could not read input file for Day 2"
    end
  end
end
