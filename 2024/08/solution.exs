defmodule Day8 do
  def parse(file) do
    input = File.read!(Path.join(Path.dirname(__ENV__.file), file))
    [{width, _}] = Regex.run(~r/\n/, input, return: :index)
    height = ceil(String.length(input) / (width + 1))
    size = {width, height}

    antennae =
      input
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.flat_map(fn {char, index} ->
        case char do
          "." ->
            []

          "\n" ->
            []

          _ ->
            y = div(index, width + 1)
            x = index - y * (width + 1)
            [{char, {x, y}}]
        end
      end)

    {size, antennae}
  end

  def group(antennae) do
    antennae |> Enum.group_by(&elem(&1, 0), &elem(&1, 1)) |> Map.values()
  end

  def antinodes([]), do: []
  def antinodes([_]), do: []

  def antinodes([a | tail]) do
    Enum.flat_map(tail, &antinodes(a, &1)) ++ antinodes(tail)
  end

  def antinodes({ax, ay}, {bx, by}) do
    dx = ax - bx
    dy = ay - by

    [
      {ax + dx, ay + dy},
      {bx - dx, by - dy}
    ]
  end

  def valid({width, height}, {x, y}) do
    x >= 0 and x < width and y >= 0 and y < height
  end

  def part1(file) do
    {size, antennae} = parse(file)

    group(antennae)
    |> Enum.flat_map(&antinodes/1)
    |> Enum.filter(&valid(size, &1))
    |> MapSet.new()
    |> MapSet.size()
  end

  def antinodes2(_, []), do: []
  def antinodes2(_, [_]), do: []

  def antinodes2(size, [a | tail]) do
    Enum.flat_map(tail, &antinodes2(size, a, &1)) ++ antinodes2(size, tail)
  end

  def antinodes2(size, {ax, ay}, {bx, by}) do
    {width, height} = size
    dx = ax - bx
    dy = ay - by
    times = min(div(width, max(1, abs(dx))), div(height, max(1, abs(dy))))

    -times..times
    |> Enum.map(fn i ->
      {ax + dx * i, ay + dy * i}
    end)
    |> Enum.filter(&valid(size, &1))
  end

  def part2(file) do
    {size, antennae} = parse(file)

    group(antennae)
    |> Enum.flat_map(&antinodes2(size, &1))
    |> MapSet.new()
    |> MapSet.size()
  end
end

Day8.part1("example.txt") |> IO.inspect(label: "part1")
Day8.part2("example.txt") |> IO.inspect(label: "part2")
