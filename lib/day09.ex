defmodule AdventOfCode2025.Day09 do
  @moduledoc """
  --- Day 9: Movie Theater ---
  You slide down the firepole in the corner of the playground and land in the North Pole base movie theater!

  The movie theater has a big tile floor with an interesting pattern. Elves here are redecorating the theater by switching out some of the square tiles in the big grid they form. Some of the tiles are red; the Elves would like to find the largest rectangle that uses red tiles for two of its opposite corners. They even have a list of where the red tiles are located in the grid (your puzzle input).

  Using two red tiles as opposite corners, what is the largest area of any rectangle you can make?

  --- Part Two ---
  The Elves just remembered: they can only switch out tiles that are red or green. So, your rectangle can only include red or green tiles.

  In your list, every red tile is connected to the red tile before and after it by a straight line of green tiles. The list wraps, so the first red tile is also connected to the last red tile. Tiles that are adjacent in your list will always be on either the same row or the same column.

  Using two red tiles as opposite corners, what is the largest area of any rectangle you can make using only red and green tiles?
  """

  @doc """
  Solves part 1 of the day 9 puzzle.
  """
  def part1(input) do
    input
    |> parse_input()
    |> solve_part1()
  end

  @doc """
  Solves part 2 of the day 9 puzzle.
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
    |> Enum.map(fn line ->
      [x, y] = String.split(line, ",")
      {String.to_integer(x), String.to_integer(y)}
    end)
  end

  defp solve_part1(red_tiles) do
    # Find the largest rectangle using any two red tiles as opposite corners
    red_tiles
    |> combinations(2)
    |> Enum.map(&calculate_rectangle_area/1)
    |> Enum.max()
  end

  # Generate all combinations of n items from a list
  defp combinations(_list, n) when n <= 0, do: [[]]
  defp combinations([], _), do: []
  defp combinations([head | tail], n) do
    with_head = Enum.map(combinations(tail, n - 1), &[head | &1])
    without_head = combinations(tail, n)
    with_head ++ without_head
  end

  # Calculate the area of a rectangle formed by two opposite corners (inclusive)
  defp calculate_rectangle_area([{x1, y1}, {x2, y2}]) do
    width = abs(x2 - x1) + 1
    height = abs(y2 - y1) + 1
    width * height
  end

  defp solve_part2(red_tiles) do
    # For large inputs, we cannot precompute all interior tiles
    # Instead, check each rectangle on-demand
    num_tiles = length(red_tiles)

    if num_tiles > 100 do
      # Large input: check validity on-demand
      solve_part2_on_demand(red_tiles)
    else
      # Small input: can precompute all green tiles
      connection_tiles = find_connection_tiles(red_tiles)
      interior_tiles = find_inside_polygon_tiles(red_tiles, connection_tiles)
      valid_tiles_set = MapSet.union(MapSet.new(red_tiles), MapSet.union(connection_tiles, interior_tiles))

      :ok

      red_tiles
      |> combinations(2)
      |> Stream.map(fn [{x1, y1}, {x2, y2}] = pair ->
        area = (abs(x2 - x1) + 1) * (abs(y2 - y1) + 1)
        {area, pair}
      end)
      |> Enum.sort_by(fn {area, _} -> area end, :desc)
      |> Enum.reduce(0, fn {_, pair}, max_so_far ->
        case calculate_rectangle_area_with_constraints(pair, valid_tiles_set) do
          nil -> max_so_far
          area -> max(area, max_so_far)
        end
      end)
    end
  end

  # On-demand checking for large inputs
  defp solve_part2_on_demand(red_tiles) do
    red_tiles_set = MapSet.new(red_tiles)
    connection_tiles = find_connection_tiles(red_tiles)
    edges = Enum.zip(red_tiles, Enum.drop(red_tiles, 1) ++ [hd(red_tiles)])

    :ok

    # Optimized approach for rectilinear polygons:
    # A rectangle is fully inside if:
    # 1. No polygon edge passes through its strict interior
    # 2. One interior point is inside the polygon (if no edge crosses, whole interior is same)

    red_tiles
    |> combinations(2)
    |> Stream.map(fn [{x1, y1}, {x2, y2}] = pair ->
      area = (abs(x2 - x1) + 1) * (abs(y2 - y1) + 1)
      {area, pair}
    end)
    |> Stream.filter(fn {_area, [{x1, y1}, {x2, y2}]} ->
      min_x = min(x1, x2)
      max_x = max(x1, x2)
      min_y = min(y1, y2)
      max_y = max(y1, y2)

      # Quick rejection: if any edge crosses the interior, this can't be valid
      not has_interior_edge_crossing?(min_x, max_x, min_y, max_y, edges)
    end)
    |> Stream.filter(fn {_area, [{x1, y1}, {x2, y2}]} ->
      min_x = min(x1, x2)
      max_x = max(x1, x2)
      min_y = min(y1, y2)
      max_y = max(y1, y2)

      # Check that all 4 corners are inside or on boundary
      # Since corners are red tiles, 2 are definitely valid
      # Check the other 2 corners
      other_corners = [{min_x, max_y}, {max_x, min_y}]
      Enum.all?(other_corners, fn c ->
        MapSet.member?(red_tiles_set, c) or
        MapSet.member?(connection_tiles, c) or
        point_inside_polygon?(c, red_tiles)
      end)
    end)
    |> Enum.sort_by(fn {area, _} -> area end, :desc)
    |> Enum.take(1)
    |> case do
      [{area, _}] -> area
      [] -> 0
    end
  end

  # Check if any polygon edge crosses through the interior of the rectangle
  defp has_interior_edge_crossing?(min_x, max_x, min_y, max_y, edges) do
    Enum.any?(edges, fn {{ex1, ey1}, {ex2, ey2}} ->
      if ex1 == ex2 do
        # Vertical edge - check if it's inside the x bounds and crosses y range
        ex1 > min_x and ex1 < max_x and
        min(ey1, ey2) < max_y and max(ey1, ey2) > min_y
      else
        # Horizontal edge - check if it's inside the y bounds and crosses x range
        ey1 > min_y and ey1 < max_y and
        min(ex1, ex2) < max_x and max(ex1, ex2) > min_x
      end
    end)
  end

  # Find tiles that connect adjacent red tiles
  defp find_connection_tiles(red_tiles) do
    # Red tiles form a loop, so each connects to next (and last connects to first)
    pairs = Enum.zip(red_tiles, Enum.drop(red_tiles, 1) ++ [hd(red_tiles)])

    Enum.reduce(pairs, MapSet.new(), fn {{x1, y1}, {x2, y2}}, acc ->
      # Find all tiles in the straight line between these two red tiles
      line_tiles = get_line_tiles({x1, y1}, {x2, y2})
      MapSet.union(acc, MapSet.new(line_tiles))
    end)
  end

  # Get all tiles in a straight line between two points (exclusive of endpoints)
  defp get_line_tiles({x1, y1}, {x2, y2}) do
    cond do
      x1 == x2 -> # Vertical line
        for y <- min(y1, y2)..max(y1, y2), y != y1 and y != y2, do: {x1, y}
      y1 == y2 -> # Horizontal line
        for x <- min(x1, x2)..max(x1, x2), x != x1 and x != x2, do: {x, y1}
      true -> # Not a straight line - shouldn't happen per problem description
        []
    end
  end

  # Find tiles inside the polygon formed by red and connection tiles
  defp find_inside_polygon_tiles(red_tiles, connection_tiles) do
    # Use ray casting algorithm to determine if points are inside polygon
    polygon_boundary = MapSet.union(MapSet.new(red_tiles), connection_tiles)

    # Find bounding box
    {min_x, max_x} = red_tiles |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
    {min_y, max_y} = red_tiles |> Enum.map(&elem(&1, 1)) |> Enum.min_max()

    for x <- min_x..max_x,
        y <- min_y..max_y,
        not MapSet.member?(polygon_boundary, {x, y}),
        point_inside_polygon?({x, y}, red_tiles),
        into: MapSet.new(),
        do: {x, y}
  end

  # Ray casting algorithm to check if point is inside polygon
  defp point_inside_polygon?({x, y}, polygon_vertices) do
    # Cast ray to the right and count intersections with polygon edges
    intersections =
      polygon_vertices
      |> Enum.zip(Enum.drop(polygon_vertices, 1) ++ [hd(polygon_vertices)])
      |> Enum.count(fn {{x1, y1}, {x2, y2}} ->
        # Check if horizontal ray from point intersects this edge
        (y1 > y) != (y2 > y) and x < (x2 - x1) * (y - y1) / (y2 - y1) + x1
      end)

    # Point is inside if number of intersections is odd
    rem(intersections, 2) == 1
  end

  # Calculate rectangle area only if all tiles in rectangle are red or green
  defp calculate_rectangle_area_with_constraints([{x1, y1}, {x2, y2}], valid_tiles) do
    min_x = min(x1, x2)
    max_x = max(x1, x2)
    min_y = min(y1, y2)
    max_y = max(y1, y2)

    # Check if all tiles in rectangle are valid (red or green)
    all_valid =
      Enum.all?(min_x..max_x, fn x ->
        Enum.all?(min_y..max_y, fn y ->
          MapSet.member?(valid_tiles, {x, y})
        end)
      end)

    if all_valid do
      (max_x - min_x + 1) * (max_y - min_y + 1)
    else
      nil
    end
  end

  @doc """
  Reads the input file for day 9.
  """
  def read_input do
    case File.read("inputs/day09.txt") do
      {:ok, content} -> content
      {:error, _} ->
        raise "Could not read input file for Day 9"
    end
  end
end
