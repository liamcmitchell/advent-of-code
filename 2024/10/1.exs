defmodule Day10 do
  def parse(file) do
    File.read!(Path.join(Path.dirname(__ENV__.file), file))
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.to_charlist()
      |> Enum.map(&(&1 - ?0))
      |> Enum.with_index(fn elevation, x -> {{x, y}, elevation} end)
    end)
    |> Map.new()
  end

  def uphill_paths(map) do
    map
    |> Enum.map(fn {pos, elevation} ->
      {x, y} = pos

      paths =
        [
          {x - 1, y},
          {x + 1, y},
          {x, y - 1},
          {x, y + 1}
        ]
        |> Enum.flat_map(fn pos2 ->
          case Map.get(map, pos2) do
            elevation2 when elevation2 == elevation + 1 -> [pos2]
            _ -> []
          end
        end)

      {pos, paths}
    end)
    |> Map.new()
  end

  def reachable_peaks(_uphill, pos, remaining) when remaining == 0, do: [pos]

  def reachable_peaks(uphill, pos, remaining) do
    Map.get(uphill, pos)
    |> Enum.flat_map(fn pos2 -> reachable_peaks(uphill, pos2, remaining - 1) end)
  end

  def part1(file) do
    map = parse(file)
    uphill = uphill_paths(map)

    map
    |> Enum.map(fn {pos, elevation} ->
      if elevation == 0 do
        reachable_peaks(uphill, pos, 9)
        |> Enum.uniq()
        |> Enum.count()
      else
        0
      end
    end)
    |> Enum.sum()
  end

  def trail_rating(_uphill, _pos, remaining) when remaining == 0, do: 1

  def trail_rating(uphill, pos, remaining) do
    Map.get(uphill, pos)
    |> Enum.map(fn pos2 -> trail_rating(uphill, pos2, remaining - 1) end)
    |> Enum.sum()
  end

  def part2(file) do
    map = parse(file)
    uphill = uphill_paths(map)

    map
    |> Enum.map(fn {pos, elevation} ->
      if elevation == 0 do
        trail_rating(uphill, pos, 9)
      else
        0
      end
    end)
    |> Enum.sum()
  end
end

Day10.part1("example") |> IO.inspect(label: "part1")
Day10.part1("input") |> IO.inspect(label: "part1")
Day10.part2("example") |> IO.inspect(label: "part2")
Day10.part2("input") |> IO.inspect(label: "part2")
