defmodule Day20 do
  def parse(file) do
    text = File.read!(Path.join(Path.dirname(__ENV__.file), file))

    for {row, y} <- Enum.with_index(String.split(text, "\n")),
        {char, x} <- Enum.with_index(String.to_charlist(row)),
        char !== ?.,
        into: %{} do
      val =
        case char do
          ?# -> :wall
          ?S -> :start
          ?E -> :end
        end

      {{x, y}, val}
    end
  end

  def visit(map, unvisited, seen, goal) do
    if :queue.is_empty(unvisited) do
      nil
    else
      path = :queue.get(unvisited)
      {pos, time} = hd(path)

      next =
        directions()
        |> Enum.map(&add(&1, pos))
        |> Enum.reject(fn pos ->
          MapSet.member?(seen, pos) or Map.get(map, pos) == :wall
        end)

      if Enum.member?(next, goal) do
        [{goal, time + 1} | path]
      else
        unvisited =
          next
          |> Enum.reduce(unvisited, fn next, unvisited ->
            :queue.in([{next, time + 1} | path], unvisited)
          end)
          |> :queue.drop()

        seen = seen |> MapSet.union(MapSet.new(next))

        visit(map, unvisited, seen, goal)
      end
    end
  end

  def shortest(map) do
    {start, _} = Enum.find(map, &match?({_, :start}, &1))
    {goal, _} = Enum.find(map, &match?({_, :end}, &1))
    unvisited = :queue.from_list([[{start, 0}]])
    seen = MapSet.new([start])
    visit(map, unvisited, seen, goal)
  end

  def directions() do
    [{0, -1}, {0, 1}, {-1, 0}, {1, 0}]
  end

  def add({ax, ay}, {bx, by}) do
    {ax + bx, ay + by}
  end

  def search_area(n) do
    for x <- -n..n,
        y <- -n..n,
        abs(x) + abs(y) <= n and not (x == 0 and y == 0) do
      {{x, y}, abs(x) + abs(y)}
    end
  end

  def cheats(path, duration, min) do
    map = Map.new(path)
    area = search_area(duration)

    path
    |> Enum.flat_map(fn {pos, time} ->
      area
      |> Enum.flat_map(fn {offset, duration} ->
        target_time = Map.get(map, add(pos, offset))

        if is_integer(target_time) do
          saved = target_time - time - duration

          if saved >= min do
            [saved]
          end
        end || []
      end)
    end)
  end

  def part(1, file) do
    parse(file) |> shortest() |> cheats(2, 100) |> Enum.count()
  end

  def part(2, file) do
    parse(file) |> shortest() |> cheats(20, 100) |> Enum.count()
  end

  def run(part, input) do
    {time, value} = :timer.tc(&part/2, [part, input])
    time = :erlang.float_to_binary(time / 1000, decimals: 1)

    IO.inspect(value, label: "Part #{part} #{input} (#{time}ms)", charlists: :as_lists)
  end
end

Day20.run(1, "example")
Day20.run(1, "input")
Day20.run(2, "example")
Day20.run(2, "input")
