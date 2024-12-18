defmodule Day18 do
  def parse(file) do
    text = File.read!(Path.join(Path.dirname(__ENV__.file), file))

    for line <- String.split(text, "\n") do
      [x, y] = String.split(line, ",")
      {String.to_integer(x), String.to_integer(y)}
    end
  end

  def part1(file, size, bytes) do
    parse(file) |> Enum.slice(0, bytes) |> shortest(size)
  end

  def shortest(bytes, size) do
    map = MapSet.new(bytes)
    start = {0, 0}
    unvisited = MapSet.new([start])
    visited = MapSet.new()
    scores = %{start => 0}
    visit(map, size, unvisited, visited, scores, start) |> Map.get({size, size})
  end

  def visit(map, size, unvisited, visited, scores, pos) do
    score = Map.get(scores, pos)

    new_scores =
      directions()
      |> Enum.reduce(%{}, fn dir, acc ->
        neighbour = add(pos, dir)

        cond do
          out_of_bounds(neighbour, size) ->
            acc

          MapSet.member?(visited, neighbour) ->
            acc

          MapSet.member?(map, neighbour) ->
            acc

          true ->
            cur_score = Map.get(scores, neighbour, 999_999)
            new_score = score + 1

            if new_score < cur_score do
              Map.put(acc, neighbour, new_score)
            else
              acc
            end
        end
      end)

    visited = MapSet.put(visited, pos)

    unvisited =
      unvisited |> MapSet.delete(pos) |> MapSet.union(new_scores |> Map.keys() |> MapSet.new())

    scores = scores |> Map.merge(new_scores)

    if MapSet.size(unvisited) == 0 do
      scores
    else
      next = unvisited |> Enum.min_by(fn pos -> scores |> Map.get(pos) end)
      visit(map, size, unvisited, visited, scores, next)
    end
  end

  def out_of_bounds({x, y}, size) do
    x < 0 or y < 0 or x > size or y > size
  end

  def directions() do
    [{0, -1}, {0, 1}, {-1, 0}, {1, 0}]
  end

  def add({ax, ay}, {bx, by}) do
    {ax + bx, ay + by}
  end

  def part2(file, size) do
    falling = parse(file)
    search(size, falling, 0, length(falling))
  end

  def search(_size, falling, min, max) when min == max - 1, do: falling |> Enum.at(min)

  def search(size, falling, min, max) do
    test = div(max - min, 2) + min

    if shortest(falling |> Enum.slice(0, test), size) do
      search(size, falling, test, max)
    else
      search(size, falling, min, test)
    end
  end
end

Day18.part1("example", 6, 12) |> IO.inspect(label: "part1 example")
Day18.part1("input", 70, 1024) |> IO.inspect(label: "part1 input")
Day18.part2("example", 6) |> IO.inspect(label: "part2 example")
Day18.part2("input", 70) |> IO.inspect(label: "part2 input")
