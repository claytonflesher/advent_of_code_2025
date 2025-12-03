defmodule AdventOfCode2025.Day03 do
  @moduledoc """
  --- Day 3: Lobby ---
  You descend a short staircase, enter the surprisingly vast lobby, and are quickly cleared by the security checkpoint. When you get to the main elevators, however, you discover that each one has a red light above it: they're all offline.

  "Sorry about that," an Elf apologizes as she tinkers with a nearby control panel. "Some kind of electrical surge seems to have fried them. I'll try to get them online soon."

  You explain your need to get further underground. "Well, you could at least take the escalator down to the printing department, not that you'd get much further than that without the elevators working. That is, you could if the escalator weren't also offline."

  "But, don't worry! It's not fried; it just needs power. Maybe you can get it running while I keep working on the elevators."

  There are batteries nearby that can supply emergency power to the escalator for just such an occasion. The batteries are each labeled with their joltage rating, a value from 1 to 9. You make a note of their joltage ratings (your puzzle input). For example:

  987654321111111
  811111111111119
  234234234234278
  818181911112111
  The batteries are arranged into banks; each line of digits in your input corresponds to a single bank of batteries. Within each bank, you need to turn on exactly two batteries; the joltage that the bank produces is equal to the number formed by the digits on the batteries you've turned on. For example, if you have a bank like 12345 and you turn on batteries 2 and 4, the bank would produce 24 jolts. (You cannot rearrange batteries.)

  You'll need to find the largest possible joltage each bank can produce. In the above example:

  In 987654321111111, you can make the largest joltage possible, 98, by turning on the first two batteries.
  In 811111111111119, you can make the largest joltage possible by turning on the batteries labeled 8 and 9, producing 89 jolts.
  In 234234234234278, you can make 78 by turning on the last two batteries (marked 7 and 8).
  In 818181911112111, the largest joltage you can produce is 92.
  The total output joltage is the sum of the maximum joltage from each bank, so in this example, the total output joltage is 98 + 89 + 78 + 92 = 357.

  There are many batteries in front of you. Find the maximum joltage possible from each bank; what is the total output joltage?

  --- Part Two ---
  The escalator doesn't move. The Elf explains that it probably needs more joltage to overcome the static friction of the system and hits the big red "joltage limit safety override" button. You lose count of the number of times she needs to confirm "yes, I'm sure" and decorate the lobby a bit while you wait.

  Now, you need to make the largest joltage by turning on exactly twelve batteries within each bank.

  The joltage output for the bank is still the number formed by the digits of the batteries you've turned on; the only difference is that now there will be 12 digits in each bank's joltage output instead of two.

  Consider again the example from before:

  987654321111111
  811111111111119
  234234234234278
  818181911112111
  Now, the joltages are much larger:

  In 987654321111111, the largest joltage can be found by turning on everything except some 1s at the end to produce 987654321111.
  In the digit sequence 811111111111119, the largest joltage can be found by turning on everything except some 1s, producing 811111111119.
  In 234234234234278, the largest joltage can be found by turning on everything except a 2 battery, a 3 battery, and another 2 battery near the start to produce 434234234278.
  In 818181911112111, the joltage 888911112111 is produced by turning on everything except some 1s near the front.
  The total output joltage is now much larger: 987654321111 + 811111111119 + 434234234278 + 888911112111 = 3121910778619.

  What is the new total output joltage?
  """

  @doc """
  Solves part 1 of the day 3 puzzle.
  """
  def part1(input) do
    input
    |> parse_input()
    |> solve_part1()
  end

  @doc """
  Solves part 2 of the day 3 puzzle.
  """
  def part2(input) do
    input
    |> parse_input()
    |> solve_part2()
  end

  @doc """
  Parses the input string into a data structure.
  """
  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(fn line -> Enum.map(line, &String.to_integer/1) end)
  end

  defp solve_part1(banks) do
    banks
    |> Enum.map(&max_joltage_from_bank/1)
    |> Enum.sum()
  end

  # Find the maximum joltage possible by selecting exactly 2 batteries from a bank
  defp max_joltage_from_bank(bank) do
    bank
    |> combinations(2)
    |> Enum.map(&form_joltage/1)
    |> Enum.max()
  end

  # Generate all combinations of selecting k items from a list
  defp combinations(_, 0), do: [[]]
  defp combinations([], _), do: []
  defp combinations([h | t], k) when k > 0 do
    (for combo <- combinations(t, k - 1), do: [h | combo]) ++ combinations(t, k)
  end

  # Form joltage from two battery values by concatenating them as digits
  defp form_joltage([a, b]) do
    a * 10 + b
  end

  defp solve_part2(banks) do
    banks
    |> Enum.map(&max_joltage_from_bank_part2/1)
    |> Enum.sum()
  end

  # Find the maximum joltage possible by selecting exactly 12 batteries from a bank
  defp max_joltage_from_bank_part2(bank) do
    # For part 2, we need to select 12 out of N batteries (remove N-12 digits)
    # where N is the length of the bank
    digits_to_remove = length(bank) - 12
    bank
    |> remove_k_digits(digits_to_remove)
    |> form_large_joltage()
  end

  # Remove k digits from a list to maximize the resulting number
  # This uses a greedy approach with a stack
  defp remove_k_digits(digits, k) do
    remove_k_digits_helper(digits, k, [])
  end

  defp remove_k_digits_helper([], k, stack) when k > 0 do
    # Remove remaining k digits from the end of stack
    stack
    |> Enum.reverse()
    |> Enum.drop(-k)
  end

  defp remove_k_digits_helper([], 0, stack) do
    Enum.reverse(stack)
  end

  defp remove_k_digits_helper([digit | rest], k, stack) when k > 0 do
    # Remove digits from stack while they are smaller than current digit
    # and we still have removals left
    {new_stack, new_k} = pop_smaller_digits(stack, digit, k)
    remove_k_digits_helper(rest, new_k, [digit | new_stack])
  end

  defp remove_k_digits_helper([digit | rest], 0, stack) do
    # No more removals left, just add remaining digits
    remove_k_digits_helper(rest, 0, [digit | stack])
  end

  # Remove smaller digits from stack while we have removals left
  defp pop_smaller_digits(stack, digit, k) do
    pop_smaller_digits_helper(stack, digit, k, [])
  end

  defp pop_smaller_digits_helper([], _digit, k, acc) do
    {acc, k}
  end

  defp pop_smaller_digits_helper([top | rest], digit, k, acc) when k > 0 and top < digit do
    pop_smaller_digits_helper(rest, digit, k - 1, acc)
  end

  defp pop_smaller_digits_helper(stack, _digit, k, acc) do
    {acc ++ stack, k}
  end  # Form joltage from 12 battery values by concatenating them as digits
  defp form_large_joltage(batteries) do
    batteries
    |> Enum.reduce(0, fn digit, acc -> acc * 10 + digit end)
  end

  @doc """
  Convenience function to solve part 1 with input from file.
  """
  def solve_part1 do
    read_input() |> part1()
  end

  @doc """
  Convenience function to solve part 2 with input from file.
  """
  def solve_part2 do
    read_input() |> part2()
  end

  @doc """
  Reads the input file for day 3.
  """
  def read_input do
    case File.read("inputs/day03.txt") do
      {:ok, content} -> content
      {:error, _} ->
        raise "Could not read input file for Day 3"
    end
  end
end
