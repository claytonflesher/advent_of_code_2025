defmodule AdventOfCode2025.Day08 do
  @moduledoc """
  --- Day 8: Playground ---
  Equipped with a new understanding of teleporter maintenance, you confidently step onto the repaired teleporter pad.

  You rematerialize on an unfamiliar teleporter pad and find yourself in a vast underground space which contains a giant playground!

  Across the playground, a group of Elves are working on setting up an ambitious Christmas decoration project. Through careful rigging, they have suspended a large number of small electrical junction boxes.

  Their plan is to connect the junction boxes with long strings of lights. Most of the junction boxes don't provide electricity; however, when two junction boxes are connected by a string of lights, electricity can pass between those two junction boxes.

  The Elves are trying to figure out which junction boxes to connect so that electricity can reach every junction box. They even have a list of all of the junction boxes' positions in 3D space (your puzzle input).

  For example:

  162,817,812
  57,618,57
  906,360,560
  592,479,940
  352,342,300
  466,668,158
  542,29,236
  431,825,988
  739,650,466
  52,470,668
  216,146,977
  819,987,18
  117,168,530
  805,96,715
  346,949,466
  970,615,88
  941,993,340
  862,61,35
  984,92,344
  425,690,689

  This list describes the position of 20 junction boxes, one per line. Each position is given as X,Y,Z coordinates. So, the first junction box in the list is at X=162, Y=817, Z=812.

  To save on string lights, the Elves would like to focus on connecting pairs of junction boxes that are as close together as possible according to straight-line distance. In this example, the two junction boxes which are closest together are 162,817,812 and 425,690,689.

  By connecting these two junction boxes together, because electricity can flow between them, they become part of the same circuit. After connecting them, there is a single circuit which contains two junction boxes, and the remaining 18 junction boxes remain in their own individual circuits.

  Now, the two junction boxes which are closest together but aren't already directly connected are 162,817,812 and 431,825,988. After connecting them, since 162,817,812 is already connected to another junction box, there is now a single circuit which contains three junction boxes and an additional 17 circuits which contain one junction box each.

  The next two junction boxes to connect are 906,360,560 and 805,96,715. After connecting them, there is a circuit containing 3 junction boxes, a circuit containing 2 junction boxes, and 15 circuits which contain one junction box each.

  The next two junction boxes are 431,825,988 and 425,690,689. Because these two junction boxes were already in the same circuit, nothing happens!

  This process continues for a while, and the Elves are concerned that they don't have enough extension cables for all these circuits. They would like to know how big the circuits will be.

  After making the ten shortest connections, there are 11 circuits: one circuit which contains 5 junction boxes, one circuit which contains 4 junction boxes, two circuits which contain 2 junction boxes each, and seven circuits which each contain a single junction box. Multiplying together the sizes of the three largest circuits (5, 4, and one of the circuits of size 2) produces 40.

  Your list contains many junction boxes; connect together the 1000 pairs of junction boxes which are closest together. Afterward, what do you get if you multiply together the sizes of the three largest circuits?

    --- Part Two ---
  The Elves were right; they definitely don't have enough extension cables. You'll need to keep connecting junction boxes together until they're all in one large circuit.

  Continuing the above example, the first connection which causes all of the junction boxes to form a single circuit is between the junction boxes at 216,146,977 and 117,168,530. The Elves need to know how far those junction boxes are from the wall so they can pick the right extension cable; multiplying the X coordinates of those two junction boxes (216 and 117) produces 25272.

  Continue connecting the closest unconnected pairs of junction boxes together until they're all in the same circuit. What do you get if you multiply together the X coordinates of the last two junction boxes you need to connect?

  """

  @doc """
  Solves part 1 of the day 8 puzzle.
  """
  def part1(input) do
    input
    |> parse_input()
    |> solve_part1()
  end



  @doc """
  Solves part 2 of the day 8 puzzle.
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
      line
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  defp solve_part1(junction_boxes, max_connections \\ 1000) do
    # Create all possible pairs with their distances
    pairs_with_distances = create_distance_pairs(junction_boxes)

    # Sort by distance (shortest first)
    sorted_pairs = Enum.sort_by(pairs_with_distances, fn {_, _, distance} -> distance end)

    # Use Union-Find to build circuits and make connections
    initial_uf = create_union_find(junction_boxes)
    {final_uf, _} = make_connections(sorted_pairs, initial_uf, max_connections)

    # Get circuit sizes and find product of three largest
    circuit_sizes = get_circuit_sizes(final_uf, junction_boxes)
    |> Enum.sort(:desc)
    |> Enum.take(3)

    Enum.reduce(circuit_sizes, 1, &(&1 * &2))
  end

  # Create all pairs of junction boxes with their Euclidean distances
  defp create_distance_pairs(junction_boxes) do
    indexed_boxes = Enum.with_index(junction_boxes)

    for {box1, i} <- indexed_boxes,
        {box2, j} <- indexed_boxes,
        i < j do
      distance = euclidean_distance(box1, box2)
      {i, j, distance}
    end
  end

  # Calculate Euclidean distance between two 3D points
  defp euclidean_distance({x1, y1, z1}, {x2, y2, z2}) do
    dx = x1 - x2
    dy = y1 - y2
    dz = z1 - z2
    :math.sqrt(dx * dx + dy * dy + dz * dz)
  end

  # Create initial Union-Find structure
  defp create_union_find(junction_boxes) do
    junction_boxes
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {_, index}, acc ->
      Map.put(acc, index, {index, 1}) # {parent, size}
    end)
  end

  # Make connections using Union-Find, process exactly max_connections pairs
  defp make_connections(sorted_pairs, uf, max_connections) do
    make_connections(sorted_pairs, uf, max_connections, 0, 0)
  end

  defp make_connections([], uf, _max_connections, _pairs_processed, connections_made) do
    {uf, connections_made}
  end

  defp make_connections(_pairs, uf, max_connections, pairs_processed, connections_made)
       when pairs_processed >= max_connections do
    {uf, connections_made}
  end

  defp make_connections([{i, j, _distance} | rest], uf, max_connections, pairs_processed, connections_made) do
    root_i = find_root(uf, i)
    root_j = find_root(uf, j)

    if root_i == root_j do
      # Already connected, skip but count the pair
      make_connections(rest, uf, max_connections, pairs_processed + 1, connections_made)
    else
      # Union the sets
      new_uf = union(uf, root_i, root_j)
      make_connections(rest, new_uf, max_connections, pairs_processed + 1, connections_made + 1)
    end
  end

  # Find root with path compression
  defp find_root(uf, node) do
    {parent, size} = Map.get(uf, node)
    if parent == node do
      node
    else
      root = find_root(uf, parent)
      # Path compression: update parent to root
      Map.put(uf, node, {root, size})
      root
    end
  end

  # Union by size
  defp union(uf, root_i, root_j) do
    {_, size_i} = Map.get(uf, root_i)
    {_, size_j} = Map.get(uf, root_j)

    if size_i >= size_j do
      # root_i becomes parent
      uf
      |> Map.put(root_i, {root_i, size_i + size_j})
      |> Map.put(root_j, {root_i, size_j})
    else
      # root_j becomes parent
      uf
      |> Map.put(root_j, {root_j, size_i + size_j})
      |> Map.put(root_i, {root_j, size_i})
    end
  end

  # Get sizes of all circuits
  defp get_circuit_sizes(uf, junction_boxes) do
    # Count how many nodes belong to each root
    junction_boxes
    |> Enum.with_index()
    |> Enum.map(fn {_, index} -> find_root(uf, index) end)
    |> Enum.frequencies()
    |> Map.values()
  end

  defp solve_part2(junction_boxes) do
    # Create all possible pairs with their distances
    pairs_with_distances = create_distance_pairs(junction_boxes)

    # Sort by distance (shortest first)
    sorted_pairs = Enum.sort_by(pairs_with_distances, fn {_, _, distance} -> distance end)

    # Use Union-Find to build circuits until everything is connected
    initial_uf = create_union_find(junction_boxes)
    {last_connection, _final_uf} = find_final_connection(sorted_pairs, initial_uf, junction_boxes)

    # Get the X coordinates of the last connection and multiply them
    {x1, _, _} = Enum.at(junction_boxes, elem(last_connection, 0))
    {x2, _, _} = Enum.at(junction_boxes, elem(last_connection, 1))
    x1 * x2
  end

  # Find the connection that causes everything to become a single circuit
  defp find_final_connection(sorted_pairs, uf, junction_boxes) do
    find_final_connection(sorted_pairs, uf, junction_boxes, nil)
  end

  defp find_final_connection([], uf, _junction_boxes, last_connection) do
    {last_connection, uf}
  end

  defp find_final_connection([{i, j, _distance} | rest], uf, junction_boxes, last_connection) do
    root_i = find_root(uf, i)
    root_j = find_root(uf, j)

    if root_i == root_j do
      # Already connected, skip
      find_final_connection(rest, uf, junction_boxes, last_connection)
    else
      # Union the sets
      new_uf = union(uf, root_i, root_j)

      # Check if everything is now in a single circuit
      circuit_count = count_circuits(new_uf, junction_boxes)

      if circuit_count == 1 do
        # This connection made everything connected - this is our answer
        {{i, j}, new_uf}
      else
        # Continue connecting
        find_final_connection(rest, new_uf, junction_boxes, {i, j})
      end
    end
  end

  # Count the number of separate circuits
  defp count_circuits(uf, junction_boxes) do
    junction_boxes
    |> Enum.with_index()
    |> Enum.map(fn {_, index} -> find_root(uf, index) end)
    |> Enum.uniq()
    |> length()
  end

  @doc """
  Reads the input file for day 8.
  """
  def read_input do
    case File.read("inputs/day08.txt") do
      {:ok, content} -> content
      {:error, _} ->
        raise "Could not read input file for Day 8"
    end
  end
end
