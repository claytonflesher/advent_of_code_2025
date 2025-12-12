defmodule AdventOfCode2025.Day12 do
  @moduledoc """
  Day 12: Christmas Tree Farm - Pack many small polyomino presents into rectangular regions.

  Part 1 asks how many regions can fit all required presents.
  """

  import Bitwise

  @doc """
  Solves part 1 of the day 12 puzzle.
  """
  def part1(input) do
    input
    |> parse_input()
    |> solve_part1()
  end

  @doc """
  Parses the input string into shapes and regions.
  """
  def parse_input(input) do
    # Split into shape definitions and region definitions
    # Shapes are numbered like "0:", "1:", etc. followed by the shape pattern
    # Regions are like "4x4: 0 0 0 0 2 0"

    lines = input |> String.trim() |> String.split("\n")

    # Find where regions start (lines with "x" in the dimensions part)
    {shape_lines, region_lines} = Enum.split_while(lines, fn line ->
      not String.match?(line, ~r/^\d+x\d+:/)
    end)

    shapes = parse_shapes(Enum.join(shape_lines, "\n"))
    regions = parse_regions(region_lines)

    {shapes, regions}
  end

  defp parse_shapes(section) do
    section
    |> String.split(~r/\n(?=\d+:)/)
    |> Enum.map(fn shape_block ->
      [_header | lines] = String.split(shape_block, "\n")
      # Convert shape to set of {x, y} coordinates where # appears
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.filter(fn {char, _x} -> char == "#" end)
        |> Enum.map(fn {_char, x} -> {x, y} end)
      end)
      |> MapSet.new()
    end)
    |> List.to_tuple()
  end

  defp parse_regions(lines) do
    lines
    |> Enum.map(fn line ->
      [dims, counts] = String.split(line, ": ")
      [width, height] = dims |> String.split("x") |> Enum.map(&String.to_integer/1)
      quantities = counts |> String.split(" ") |> Enum.map(&String.to_integer/1)
      {width, height, quantities}
    end)
  end

  defp solve_part1({shapes, regions}) do
    regions
    |> Enum.count(fn region -> can_fit_all?(shapes, region) end)
  end

  defp can_fit_all?(shapes, {width, height, quantities}) do
    total_pieces = Enum.sum(quantities)

    cond do
      total_pieces == 0 ->
        true

      width < 3 or height < 3 ->
        # All input shapes are at least 3x3 in bounding box.
        false

      true ->
        grid_area = width * height

        total_piece_area =
          quantities
          |> Enum.with_index()
          |> Enum.reduce(0, fn {count, idx}, acc -> acc + count * MapSet.size(elem(shapes, idx)) end)

        # Necessary condition
        if total_piece_area > grid_area do
          false
        else
          # Fast sufficient condition:
          # If we can assign each present to its own disjoint 3x3 block, we can always pack
          # (place each present inside its own block; blocks don't overlap).
          blocks = div(width, 3) * div(height, 3)

          if total_pieces <= blocks do
            true
          else
            # Only happens for small/tight regions; use a memoized bitmask backtracker.
            can_fit_all_backtrack?(shapes, {width, height, quantities})
          end
        end
    end
  end

  defp can_fit_all_backtrack?(shapes, {width, height, quantities}) do
    # Keep only shapes we actually need, sorted by decreasing area.
    needed =
      quantities
      |> Enum.with_index()
      |> Enum.filter(fn {count, _idx} -> count > 0 end)
      |> Enum.sort_by(fn {_count, idx} -> -MapSet.size(elem(shapes, idx)) end)

    counts = Enum.map(needed, fn {count, _idx} -> count end)

    placements_by_type =
      Enum.map(needed, fn {_count, idx} ->
        shape = elem(shapes, idx)
        orientations = all_orientations(shape)
        placements_for_type(orientations, width, height)
      end)

    {result, _cache} = search_memo(0, counts, placements_by_type, %{})
    result
  end

  defp search_memo(occupied, counts, placements_by_type, cache) do
    if Enum.all?(counts, &(&1 == 0)) do
      {true, cache}
    else
    key = {occupied, counts}

    case Map.fetch(cache, key) do
      {:ok, result} ->
        {result, cache}

      :error ->
        {choice, cache2} = choose_next_type(occupied, counts, placements_by_type, cache)

        result =
          case choice do
            :dead_end ->
              {false, cache2}

            {type_idx, valid_masks} ->
              Enum.reduce_while(valid_masks, {false, cache2}, fn mask, {_acc_bool, acc_cache} ->
                new_counts = List.update_at(counts, type_idx, &(&1 - 1))
                {ok, cache3} = search_memo(occupied ||| mask, new_counts, placements_by_type, acc_cache)

                if ok do
                  {:halt, {true, cache3}}
                else
                  {:cont, {false, cache3}}
                end
              end)
          end

        {bool, cacheN} = result
        cache_final = Map.put(cacheN, key, bool)
        {bool, cache_final}
    end
    end
  end

  defp choose_next_type(occupied, counts, placements_by_type, cache) do
    # MRV: pick the remaining type with the fewest placements that still fit.
    candidates =
      counts
      |> Enum.with_index()
      |> Enum.filter(fn {count, _idx} -> count > 0 end)
      |> Enum.map(fn {_count, idx} ->
        masks = Enum.filter(Enum.at(placements_by_type, idx), fn mask -> (mask &&& occupied) == 0 end)
        {idx, masks}
      end)

    case candidates do
      [] ->
        {:dead_end, cache}

      _ ->
        {idx, masks} = Enum.min_by(candidates, fn {_idx, masks} -> length(masks) end)
        if masks == [], do: {:dead_end, cache}, else: {{idx, masks}, cache}
    end
  end

  defp placements_for_type(orientations, width, height) do
    orientations
    |> Enum.flat_map(fn shape ->
      {max_x, max_y} = max_xy(shape)

      for dx <- 0..(width - max_x - 1),
          dy <- 0..(height - max_y - 1) do
        shape_to_mask(shape, width, dx, dy)
      end
    end)
    |> Enum.uniq()
  end

  defp shape_to_mask(shape, width, dx, dy) do
    Enum.reduce(shape, 0, fn {x, y}, acc ->
      bit = 1 <<< ((y + dy) * width + (x + dx))
      acc ||| bit
    end)
  end

  defp max_xy(shape) do
    Enum.reduce(shape, {0, 0}, fn {x, y}, {mx, my} -> {max(mx, x), max(my, y)} end)
  end

  defp all_orientations(shape) do
    # Generate all 8 possible orientations (4 rotations x 2 flips)
    rotations = [shape, rotate90(shape), rotate90(rotate90(shape)), rotate90(rotate90(rotate90(shape)))]
    flipped = Enum.map(rotations, &flip_horizontal/1)

    (rotations ++ flipped)
    |> Enum.map(&normalize/1)
    |> Enum.uniq()
  end

  defp rotate90(shape) do
    # Rotate 90 degrees clockwise: (x, y) -> (max_y - y, x)
    max_y = shape |> Enum.map(&elem(&1, 1)) |> Enum.max()
    shape |> Enum.map(fn {x, y} -> {max_y - y, x} end) |> MapSet.new()
  end

  defp flip_horizontal(shape) do
    max_x = shape |> Enum.map(&elem(&1, 0)) |> Enum.max()
    shape |> Enum.map(fn {x, y} -> {max_x - x, y} end) |> MapSet.new()
  end

  defp normalize(shape) do
    # Translate shape so minimum x and y are 0
    min_x = shape |> Enum.map(&elem(&1, 0)) |> Enum.min()
    min_y = shape |> Enum.map(&elem(&1, 1)) |> Enum.min()
    shape |> Enum.map(fn {x, y} -> {x - min_x, y - min_y} end) |> MapSet.new()
  end

  @doc """
  Reads the input file for day 12.
  """
  def read_input do
    case File.read("inputs/day12.txt") do
      {:ok, content} -> content
      {:error, _} ->
        raise "Could not read input file for Day 12"
    end
  end
end
