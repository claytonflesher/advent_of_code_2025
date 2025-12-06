defmodule AdventOfCode2025.Day06 do
  @moduledoc """
  --- Day 6: Trash Compactor ---
  After helping the Elves in the kitchen, you were taking a break and helping them re-enact a movie scene when you over-enthusiastically jumped into the garbage chute!

  A brief fall later, you find yourself in a garbage smasher. Unfortunately, the door's been magnetically sealed.

  As you try to find a way out, you are approached by a family of cephalopods! They're pretty sure they can get the door open, but it will take some time. While you wait, they're curious if you can help the youngest cephalopod with her math homework.

  Cephalopod math doesn't look that different from normal math. The math worksheet (your puzzle input) consists of a list of problems; each problem has a group of numbers that need to either be either added (+) or multiplied (*) together.

  However, the problems are arranged a little strangely; they seem to be presented next to each other in a very long horizontal list. For example:

  123 328  51 64
   45 64  387 23
    6 98  215 314
  *   +   *   +
  Each problem's numbers are arranged vertically; at the bottom of the problem is the symbol for the operation that needs to be performed. Problems are separated by a full column of only spaces. The left/right alignment of numbers within each problem can be ignored.

  So, this worksheet contains four problems:

  123 * 45 * 6 = 33210
  328 + 64 + 98 = 490
  51 * 387 * 215 = 4243455
  64 + 23 + 314 = 401
  To check their work, cephalopod students are given the grand total of adding together all of the answers to the individual problems. In this worksheet, the grand total is 33210 + 490 + 4243455 + 401 = 4277556.

  Of course, the actual worksheet is much wider. You'll need to make sure to unroll it completely so that you can read the problems clearly.

  Solve the problems on the math worksheet. What is the grand total found by adding together all of the answers to the individual problems?

  --- Part Two ---
  The big cephalopods come back to check on how things are going. When they see that your grand total doesn't match the one expected by the worksheet, they realize they forgot to explain how to read cephalopod math.

  Cephalopod math is written right-to-left in columns. Each number is given in its own column, with the most significant digit at the top and the least significant digit at the bottom. (Problems are still separated with a column consisting only of spaces, and the symbol at the bottom of the problem is still the operator to use.)

  Here's the example worksheet again:

  123 328  51 64
   45 64  387 23
    6 98  215 314
  *   +   *   +
  Reading the problems right-to-left one column at a time, the problems are now quite different:

  The rightmost problem is 4 + 431 + 623 = 1058
  The second problem from the right is 175 * 581 * 32 = 3253600
  The third problem from the right is 8 + 248 + 369 = 625
  Finally, the leftmost problem is 356 * 24 * 1 = 8544
  Now, the grand total is 1058 + 3253600 + 625 + 8544 = 3263827.

  Solve the problems on the math worksheet again. What is the grand total found by adding together all of the answers to the individual problems?


  """

  @doc """
  Solves part 1 of the day 6 puzzle.
  """
  def part1(input) do
    input
    |> parse_input()
    |> solve_part1()
  end

  @doc """
  Solves part 2 of the day 6 puzzle.
  """
  def part2(input) do
    # Parse using position-based cephalopod math
    lines = String.split(String.trim(input), "\n")
    number_lines = Enum.take(lines, length(lines) - 1)
    operator_line = List.last(lines)

    # Find the maximum line length
    max_length = Enum.map(number_lines, &String.length/1) |> Enum.max()

    # Find space-only columns that separate problems
    separator_positions = for pos <- 0..(max_length-1) do
      chars_at_pos = Enum.map(number_lines, fn line ->
        if pos < String.length(line) do
          String.at(line, pos)
        else
          " "
        end
      end)

      if Enum.all?(chars_at_pos, fn char -> char == " " end) do
        pos
      else
        nil
      end
    end |> Enum.reject(&is_nil/1)

    # Create problem boundaries
    boundaries = [-1] ++ separator_positions ++ [max_length]
    problem_ranges = Enum.chunk_every(boundaries, 2, 1, :discard)
    |> Enum.map(fn [start, stop] -> (start+1)..(stop-1) end)

    # Collect digits by position
    position_digits =
      Enum.with_index(number_lines)
      |> Enum.reduce(%{}, fn {line, line_idx}, acc ->
        String.graphemes(line)
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {char, pos}, inner_acc ->
          if char != " " do
            current = Map.get(inner_acc, pos, [])
            Map.put(inner_acc, pos, current ++ [{char, line_idx}])
          else
            inner_acc
          end
        end)
      end)

    # Parse each problem by its position range
    problems = Enum.map(problem_ranges, fn range ->
      positions = Enum.to_list(range)

      # Get operator from the first position in the range
      operator = case positions do
        [first_pos | _] ->
          operator_char = String.at(operator_line, first_pos)
          if operator_char in ["*", "+"], do: operator_char, else: "*"
        [] -> "*"
      end

      # Get numbers from each position in the range
      numbers = Enum.map(positions, fn pos ->
        case Map.get(position_digits, pos) do
          nil -> nil
          digits_info ->
            digits = Enum.map(digits_info, fn {digit, _line} -> digit end)
            case digits do
              [] -> nil
              _ -> Enum.join(digits, "") |> String.to_integer()
            end
        end
      end) |> Enum.reject(&is_nil/1)

      {numbers, operator}
    end)

    # Return problems in right-to-left order and solve them
    problems
    |> Enum.reverse()
    |> Enum.map(fn {numbers, operator} ->
      case operator do
        "*" -> Enum.reduce(numbers, 1, &(&1 * &2))
        "+" -> Enum.sum(numbers)
      end
    end)
    |> Enum.sum()
  end

  @doc """
  Parses the input string into a data structure.
  """
  def parse_input(input) do
    lines = input
    |> String.trim()
    |> String.split("\n")

    # Last line contains operations, others contain numbers
    {number_lines, [operation_line]} = Enum.split(lines, -1)

    # Parse each column as a separate problem
    parse_columns(number_lines, operation_line)
  end

  # Parse input for Part 2 - right-to-left number formation based on spacing
  def parse_input_part2(input) do
    lines = input
    |> String.trim()
    |> String.split("\n")

    # Last line contains operations, others contain numbers
    {number_lines, [operation_line]} = Enum.split(lines, -1)

    # Parse based on character positions to respect spacing
    parse_columns_by_position(number_lines, operation_line)
  end

  # Parse columns for Part 2 - based on character position alignment
  defp parse_columns_by_position(number_lines, operation_line) do
    # Find all digit positions across all lines
    digit_positions = extract_digit_positions(number_lines)

    # Find operation positions to determine column boundaries
    operation_positions = extract_operation_positions(operation_line)

    # Group digit columns based on operation positions
    columns = group_into_conceptual_columns(digit_positions, operation_positions)

    # Process columns right-to-left
    columns
    |> Enum.reverse()
    |> Enum.map(fn {operation, column_digits} ->
      # Apply cephalopod math to each position group within the column
      position_groups = column_digits
      |> Enum.group_by(fn {_row, pos, _digit} -> pos end)
      |> Enum.sort_by(fn {pos, _} -> pos end)
      |> Enum.reverse() # Process positions right-to-left within column

      cephalopod_numbers = position_groups
      |> Enum.map(fn {_pos, digits} ->
        # Extract just the digit values in row order
        digit_values = digits
        |> Enum.sort_by(fn {row, _pos, _digit} -> row end)
        |> Enum.map(fn {_row, _pos, digit} -> digit end)

        # Apply significant digit algorithm to this position
        if length(digit_values) > 0 do
          digit_arrays = Enum.map(digit_values, &[&1])
          result = extract_by_significance(digit_arrays, [])
          List.first(result) # Each position should give one number
        else
          nil
        end
      end)
      |> Enum.filter(&(&1 != nil))

      {cephalopod_numbers, operation}
    end)
  end

  # Group digit positions into conceptual columns based on operation positions
  defp group_into_conceptual_columns(digit_positions, operation_positions) do
    # Define column boundaries based on operation positions
    column_boundaries = operation_positions
    |> Enum.with_index()
    |> Enum.map(fn {{operation, op_pos}, idx} ->
      # Calculate the start and end positions for this column
      start_pos = op_pos
      end_pos = if idx < length(operation_positions) - 1 do
        {_, next_op_pos} = Enum.at(operation_positions, idx + 1)
        next_op_pos - 1
      else
        # Last column goes to the end
        99
      end

      {operation, start_pos, end_pos}
    end)

    # Group digits by these boundaries
    column_boundaries
    |> Enum.map(fn {operation, start_pos, end_pos} ->
      column_digits = digit_positions
      |> Enum.filter(fn {_row, digit_pos, _digit} ->
        digit_pos >= start_pos && digit_pos <= end_pos
      end)

      {operation, column_digits}
    end)
  end

  # Extract digit positions from number lines, preserving spacing
  defp extract_digit_positions(number_lines) do
    number_lines
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, row_idx} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.filter(fn {char, _} -> Regex.match?(~r/\d/, char) end)
      |> Enum.map(fn {digit, col_pos} -> {row_idx, col_pos, String.to_integer(digit)} end)
    end)
  end

  # Extract operation positions from operation line
  defp extract_operation_positions(operation_line) do
    operation_line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.filter(fn {char, _} -> char in ["+", "*"] end)
  end

  # Extract numbers by significance level (from highest to lowest)
  defp extract_by_significance(digit_arrays, acc) do
    # Find the maximum number of digits remaining
    max_digits = digit_arrays |> Enum.map(&length/1) |> Enum.max(fn -> 0 end)

    if max_digits == 0 do
      # No more digits to process
      Enum.reverse(acc)
    else
      # Find numbers that have the maximum number of digits
      active_numbers = digit_arrays
      |> Enum.with_index()
      |> Enum.filter(fn {digits, _} -> length(digits) == max_digits end)

      # Take the rightmost digit from each active number
      extracted_digits = active_numbers
      |> Enum.map(fn {digits, _} -> List.last(digits) end)

      # Form number by reading digits from top to bottom
      number = extracted_digits |> Enum.join() |> String.to_integer()

      # Remove the rightmost digit from numbers that contributed
      updated_arrays = digit_arrays
      |> Enum.map(fn digits ->
        if length(digits) == max_digits do
          Enum.drop(digits, -1)  # Remove rightmost digit
        else
          digits  # Keep unchanged if not at max length
        end
      end)

      extract_by_significance(updated_arrays, [number | acc])
    end
  end

  # Extract numbers from a specific column index across all rows
  defp extract_column_numbers(number_rows, col_idx) do
    number_rows
    |> Enum.map(fn row -> Enum.at(row, col_idx) end)
    |> Enum.filter(& &1 != nil)  # Remove nils for shorter rows
    |> Enum.map(&String.to_integer/1)
  end

  # Parse columns for Part 1
  defp parse_columns(number_lines, operation_line) do
    # Split each line into words (space-separated tokens)
    number_rows = Enum.map(number_lines, &String.split/1)
    operation_tokens = String.split(operation_line)

    # Find the maximum number of columns
    max_cols = number_rows |> Enum.map(&length/1) |> Enum.max()

    # Extract each column as a problem
    for col_idx <- 0..(max_cols - 1) do
      numbers = extract_column_numbers(number_rows, col_idx)
      operation = Enum.at(operation_tokens, col_idx)
      {numbers, operation}
    end
    |> Enum.filter(fn {numbers, operation} ->
      # Only include columns that have an operation and at least one number
      operation != nil and length(numbers) > 0
    end)
  end

  defp solve_part1(problems) do
    problems
    |> Enum.map(&solve_problem/1)
    |> Enum.sum()
  end

  # Solve a single math problem (numbers with operation)
  defp solve_problem({numbers, "+"}) do
    Enum.sum(numbers)
  end

  defp solve_problem({numbers, "*"}) do
    Enum.reduce(numbers, 1, &*/2)
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
  Reads the input file for day 6.
  """
  def read_input do
    case File.read("inputs/day06.txt") do
      {:ok, content} -> content
      {:error, _} ->
        raise "Could not read input file for Day 6"
    end
  end
end
