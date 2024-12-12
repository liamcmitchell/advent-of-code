defmodule Day12 do
  def parse(file) do
    File.read!(Path.join(Path.dirname(__ENV__.file), file))
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line |> String.graphemes() |> Enum.with_index(fn region, x -> {{x, y}, region} end)
    end)
    |> Map.new()
  end

  def directions() do
    [{0, -1}, {0, 1}, {-1, 0}, {1, 0}]
  end

  def add({ax, ay}, {bx, by}) do
    {ax + bx, ay + by}
  end

  def parts(map, counted, region, pos) do
    case map do
      %{^pos => ^region} ->
        if MapSet.member?(counted, pos) do
          {counted, 0, 0}
        else
          directions()
          |> Enum.map(&add(pos, &1))
          |> Enum.reduce({MapSet.put(counted, pos), 1, 0}, fn neighbour,
                                                              {counted, area, borders} ->
            {updated_counted, additional_area, additional_borders} =
              parts(map, counted, region, neighbour)

            {updated_counted, area + additional_area, borders + additional_borders}
          end)
        end

      _ ->
        {counted, 0, 1}
    end
  end

  def part1(file) do
    map = parse(file)

    map
    |> Map.keys()
    |> Enum.reduce({0, MapSet.new()}, fn pos, {sum, counted} ->
      {updated_counted, area, borders} = parts(map, counted, Map.get(map, pos), pos)
      {sum + area * borders, updated_counted}
    end)
    |> elem(0)
  end

  def fence_posts({ax, ay}, {bx, by}, direction) do
    horizontal_fence = ax == bx
    a = {max(ax, bx), max(ay, by)}
    b = if horizontal_fence, do: add(a, {1, 0}), else: add(a, {0, 1})

    {
      {a, direction},
      {b, direction}
    }
  end

  def borders(positions) do
    positions
    |> Enum.reduce(%{}, fn pos, borders ->
      directions()
      |> Enum.reduce(borders, fn direction, borders ->
        neighbour = add(pos, direction)

        if !MapSet.member?(positions, neighbour) do
          {a, b} = fence_posts(pos, neighbour, direction)

          case borders do
            %{^a => a2, ^b => b2} ->
              borders |> Map.delete(a) |> Map.delete(b) |> Map.put(a2, b2) |> Map.put(b2, a2)

            %{^a => a2} ->
              borders |> Map.delete(a) |> Map.put(a2, b) |> Map.put(b, a2)

            %{^b => b2} ->
              borders |> Map.delete(b) |> Map.put(a, b2) |> Map.put(b2, a)

            _ ->
              borders |> Map.put(a, b) |> Map.put(b, a)
          end
        else
          borders
        end
      end)
    end)
  end

  def part2(file) do
    map = parse(file)

    map
    |> Map.keys()
    |> Enum.reduce({0, MapSet.new()}, fn pos, {sum, counted} ->
      {updated_counted, area, _borders} = parts(map, counted, Map.get(map, pos), pos)

      if area > 0 do
        sides =
          updated_counted
          |> MapSet.difference(counted)
          |> borders()
          |> map_size()
          |> div(2)

        {sum + area * sides, updated_counted}
      else
        {sum, updated_counted}
      end
    end)
    |> elem(0)
  end
end

Day12.part1("example") |> IO.inspect(label: "part1 example")
Day12.part1("input") |> IO.inspect(label: "part1 input")
Day12.part2("example") |> IO.inspect(label: "part2 example")
Day12.part2("exampleE") |> IO.inspect(label: "part2 exampleE")
Day12.part2("exampleAB") |> IO.inspect(label: "part2 exampleAB")
Day12.part2("input") |> IO.inspect(label: "part2 input")
