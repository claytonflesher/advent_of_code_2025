defmodule AdventOfCode2025.Day10 do
  @moduledoc """
  Day 10: Factory - Joltage counter calibration using linear algebra.

  Part 1: Count lights that are ON after toggling sequences.
  Part 2: Find minimum button presses to reach target joltage values using
  Gauss-Jordan elimination and branch-and-bound search.
  @doc """
  Solves part 1 of the day 10 puzzle.
  """
  def part1(input) do
    input
    |> parse_input()
    |> solve_part1()
  end

  @doc """
  Solves part 2 of the day 10 puzzle.
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
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    # Extract indicator light diagram [...]
    [_, diagram] = Regex.run(~r/\[([.#]+)\]/, line)

    # Extract all button wiring schematics (...)
    buttons = Regex.scan(~r/\(([0-9,]*)\)/, line)
    |> Enum.map(fn [_, contents] ->
      if contents == "" do
        []
      else
        contents
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
      end
    end)

    # Extract joltage requirements {...}
    [_, joltage_str] = Regex.run(~r/\{([0-9,]+)\}/, line)
    joltage = joltage_str
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)

    # Parse target state from diagram
    target = diagram
    |> String.graphemes()
    |> Enum.map(fn
      "#" -> 1
      "." -> 0
    end)

    %{
      num_lights: String.length(diagram),
      target: target,
      buttons: buttons,
      joltage: joltage
    }
  end

  defp solve_part1(machines) do
    machines
    |> Enum.map(&find_minimum_presses/1)
    |> Enum.sum()
  end

  defp find_minimum_presses(%{num_lights: num_lights, target: target, buttons: buttons}) do
    # Use BFS to find minimum button presses
    # State is the current light configuration (list of 0/1)
    initial_state = List.duplicate(0, num_lights)

    if initial_state == target do
      0
    else
      bfs_minimum_presses(initial_state, target, buttons)
    end
  end

  defp bfs_minimum_presses(initial_state, target, buttons) do
    # BFS with state being current lights config
    # Each step tries pressing each button
    queue = :queue.from_list([{initial_state, 0}])
    visited = MapSet.new([initial_state])

    bfs_loop(queue, visited, target, buttons)
  end

  defp bfs_loop(queue, visited, target, buttons) do
    case :queue.out(queue) do
      {:empty, _} ->
        # No solution found (shouldn't happen for valid inputs)
        :infinity

      {{:value, {state, presses}}, rest_queue} ->
        # Try pressing each button
        try_buttons(state, presses, buttons, target, rest_queue, visited)
    end
  end

  defp try_buttons(state, presses, buttons, target, queue, visited) do
    result = Enum.reduce_while(buttons, {queue, visited}, fn button, {q, v} ->
      new_state = toggle_lights(state, button)

      cond do
        new_state == target ->
          {:halt, {:found, presses + 1}}

        MapSet.member?(v, new_state) ->
          {:cont, {q, v}}

        true ->
          new_queue = :queue.in({new_state, presses + 1}, q)
          new_visited = MapSet.put(v, new_state)
          {:cont, {new_queue, new_visited}}
      end
    end)

    case result do
      {:found, total_presses} -> total_presses
      {new_queue, new_visited} -> bfs_loop(new_queue, new_visited, target, buttons)
    end
  end

  defp toggle_lights(state, button_indices) do
    state
    |> Enum.with_index()
    |> Enum.map(fn {light, idx} ->
      if idx in button_indices do
        1 - light  # Toggle: 0 -> 1, 1 -> 0
      else
        light
      end
    end)
  end

  defp solve_part2(machines) do
    # Process machines in parallel using Task.async_stream
    machines
    |> Task.async_stream(&find_minimum_joltage_presses/1,
      max_concurrency: System.schedulers_online(),
      timeout: :infinity
    )
    |> Enum.map(fn {:ok, result} -> result end)
    |> Enum.sum()
  end

  defp find_minimum_joltage_presses(%{buttons: buttons, joltage: joltage}) do
    num_counters = length(joltage)
    num_buttons = length(buttons)

    # Build matrix A where A[i][j] = 1 if button j affects counter i
    # We want to solve A * x = b (joltage) for non-negative integer x
    matrix = for c <- 0..(num_counters - 1) do
      for b <- 0..(num_buttons - 1) do
        if c in Enum.at(buttons, b), do: {1, 1}, else: {0, 1}
      end ++ [{Enum.at(joltage, c), 1}]  # Augmented with target
    end

    # Gauss-Jordan elimination
    {reduced, pivot_cols} = gauss_jordan(matrix, num_buttons)

    # Find minimum cost solution
    free_vars = Enum.to_list(0..(num_buttons - 1)) -- pivot_cols
    find_min_solution(reduced, pivot_cols, free_vars, num_buttons)
  end

  def gauss_jordan(matrix, num_cols) do
    num_rows = length(matrix)

    {result, pivots, _} = Enum.reduce(0..(num_cols - 1), {matrix, [], 0}, fn col, {mat, pivot_list, row} ->
      if row >= num_rows do
        {mat, pivot_list, row}
      else
        # Find pivot
        pivot_row = Enum.find(row..(num_rows - 1), fn r ->
          {n, _} = elem_at(mat, r, col)
          n != 0
        end)

        if pivot_row == nil do
          {mat, pivot_list, row}
        else
          # Swap if needed
          mat = if pivot_row != row, do: swap(mat, row, pivot_row), else: mat

          # Scale pivot row
          pivot = elem_at(mat, row, col)
          mat = scale(mat, row, inv(pivot))

          # Eliminate in other rows
          mat = for {r, r_idx} <- Enum.with_index(mat) do
            if r_idx == row do
              r
            else
              factor = Enum.at(r, col)
              if elem(factor, 0) == 0 do
                r
              else
                sub_rows(r, Enum.at(mat, row), factor)
              end
            end
          end

          {mat, pivot_list ++ [col], row + 1}
        end
      end
    end)

    {result, pivots}
  end

  defp elem_at(mat, r, c), do: Enum.at(Enum.at(mat, r), c)

  defp swap(mat, r1, r2) do
    row1 = Enum.at(mat, r1)
    row2 = Enum.at(mat, r2)
    mat |> List.replace_at(r1, row2) |> List.replace_at(r2, row1)
  end

  defp scale(mat, row, s) do
    new_row = Enum.at(mat, row) |> Enum.map(&mul(&1, s))
    List.replace_at(mat, row, new_row)
  end

  defp sub_rows(row1, row2, factor) do
    Enum.zip(row1, row2) |> Enum.map(fn {a, b} -> sub(a, mul(b, factor)) end)
  end

  # Rational arithmetic
  defp mul({n1, d1}, {n2, d2}), do: simplify({n1 * n2, d1 * d2})
  defp inv({n, d}), do: simplify({d, n})
  defp sub({n1, d1}, {n2, d2}), do: simplify({n1 * d2 - n2 * d1, d1 * d2})
  defp add({n1, d1}, {n2, d2}), do: simplify({n1 * d2 + n2 * d1, d1 * d2})

  defp simplify({0, _}), do: {0, 1}
  defp simplify({n, d}) do
    g = Integer.gcd(abs(n), abs(d))
    s = if d < 0, do: -1, else: 1
    {s * div(n, g), s * div(d, g)}
  end

  def find_min_solution(reduced, pivot_cols, free_vars, num_buttons) do
    if free_vars == [] do
      # Unique solution
      sol = extract_sol(reduced, pivot_cols, num_buttons, %{})
      if valid?(sol), do: cost(sol), else: :infinity
    else
      # Compute upper bound for each free variable
      max_bounds = compute_upper_bounds(reduced, pivot_cols, free_vars)

      # Sort free variables by their bounds (smallest first) for better pruning
      pairs = Enum.zip(free_vars, max_bounds) |> Enum.sort_by(fn {_, bound} -> bound end)
      {sorted_free_vars, sorted_bounds} = Enum.unzip(pairs)

      # Use branch and bound search
      branch_and_bound(reduced, pivot_cols, sorted_free_vars, num_buttons, sorted_bounds, [], :infinity)
    end
  end



  defp compute_upper_bounds(reduced, _pivot_cols, free_vars) do
    # The interaction between free variables makes computing tight independent bounds complex
    # For safety, use a generous upper bound based on max RHS value
    # The branch_and_bound search will filter out invalid solutions
    max_rhs = reduced
    |> Enum.map(fn row ->
      {n, d} = List.last(row)
      abs(div(n, d))
    end)
    |> Enum.max(fn -> 100 end)
    |> max(100)

    # Use max_rhs as the bound for all free variables
    # This ensures we don't miss valid solutions due to overly tight bounds
    Enum.map(free_vars, fn _fv -> max_rhs end)
  end

  defp branch_and_bound(reduced, pivot_cols, [], num_buttons, _max_bounds, assignment_list, best) do
    # All free vars assigned - compute solution
    assignment = Enum.into(assignment_list, %{})
    sol = extract_sol(reduced, pivot_cols, num_buttons, assignment)
    if valid?(sol) do
      c = cost(sol)
      if c < best, do: c, else: best
    else
      best
    end
  end

  defp branch_and_bound(reduced, pivot_cols, [fv | rest_fv], num_buttons, [max | rest_max], assignment_list, best) do
    # Try values for this free variable with early termination
    # Sum of current assignments gives lower bound on solution cost
    current_sum = Enum.sum(Enum.map(assignment_list, fn {_, v} -> v end))

    Enum.reduce_while(0..max, best, fn val, current_best ->
      # Prune: if current assignments already exceed best, stop searching higher values
      if current_sum + val >= current_best do
        {:halt, current_best}
      else
        new_assignment = [{fv, val} | assignment_list]
        new_best = branch_and_bound(reduced, pivot_cols, rest_fv, num_buttons, rest_max, new_assignment, current_best)
        {:cont, new_best}
      end
    end)
  end

  def extract_sol(reduced, pivot_cols, num_buttons, free_assign) do
    base = for i <- 0..(num_buttons - 1), into: %{}, do: {i, Map.get(free_assign, i, 0)}

    Enum.with_index(pivot_cols)
    |> Enum.reduce(base, fn {col, row_idx}, acc ->
      if row_idx >= length(reduced) do
        acc
      else
        row = Enum.at(reduced, row_idx)
        rhs = List.last(row)

        # Subtract contributions from free vars
        contrib = Enum.reduce(0..(num_buttons - 1), {0, 1}, fn c, sum ->
          if c == col or c in pivot_cols do
            sum
          else
            coeff = Enum.at(row, c)
            val = Map.get(acc, c, 0)
            add(sum, mul(coeff, {val, 1}))
          end
        end)

        {vn, vd} = sub(rhs, contrib)
        val = if vd != 0 and rem(vn, vd) == 0, do: div(vn, vd), else: :invalid
        Map.put(acc, col, val)
      end
    end)
  end

  def valid?(sol), do: Enum.all?(Map.values(sol), &(is_integer(&1) and &1 >= 0))
  def cost(sol), do: Enum.sum(Map.values(sol))

  @doc """
  Reads the input file for day 10.
  """
  def read_input do
    case File.read("inputs/day10.txt") do
      {:ok, content} -> content
      {:error, _} ->
        raise "Could not read input file for Day 10"
    end
  end
end
