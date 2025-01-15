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
    goal = {size, size}
    unvisited = :queue.from_list([{0, start}])
    seen = MapSet.new([start])
    visit(map, size, unvisited, seen, goal)
  end

  def visit(map, size, unvisited, seen, goal) do
    if :queue.is_empty(unvisited) do
      nil
    else
      {score, pos} = :queue.get(unvisited)

      next =
        directions()
        |> Enum.map(&add(&1, pos))
        |> Enum.reject(fn pos ->
          out_of_bounds(pos, size) or MapSet.member?(seen, pos) or MapSet.member?(map, pos)
        end)

      if Enum.member?(next, goal) do
        score + 1
      else
        unvisited =
          next
          |> Enum.reduce(unvisited, fn next, unvisited ->
            :queue.in({score + 1, next}, unvisited)
          end)
          |> :queue.drop()

        seen = seen |> MapSet.union(MapSet.new(next))

        visit(map, size, unvisited, seen, goal)
      end
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

Day18.part1("example.txt", 6, 12) |> IO.inspect(label: "part1 example")
Day18.part1("input.txt", 70, 1024) |> IO.inspect(label: "part1 input")
Day18.part2("example.txt", 6) |> IO.inspect(label: "part2 example")
Day18.part2("input.txt", 70) |> IO.inspect(label: "part2 input")
