defmodule Day14 do
  def parse(file) do
    text = File.read!(Path.join(Path.dirname(__ENV__.file), file))

    Regex.scan(
      ~r/p=(\d+),(\d+) v=(-?\d+),(-?\d+)/,
      text
    )
    |> Enum.map(fn [_match | groups] ->
      [px, py, vx, vy] = Enum.map(groups, &String.to_integer/1)
      {{px, py}, {vx, vy}}
    end)
  end

  def part1(file, size) do
    parse(file)
    |> Enum.map(fn {pos, vel} ->
      vel |> multiply(100) |> add(pos) |> wrap(size)
    end)
    |> Enum.map(&section(&1, size))
    |> Enum.reject(&is_nil/1)
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.reduce(&*/2)
  end

  def add({x1, y1}, {x2, y2}) do
    {x1 + x2, y1 + y2}
  end

  def multiply({x, y}, factor) do
    {x * factor, y * factor}
  end

  def wrap({x1, y1}, {x2, y2}) do
    {wrap(x1, x2), wrap(y1, y2)}
  end

  def wrap(a, b) do
    a = rem(a, b)

    if a < 0 do
      a + b
    else
      a
    end
  end

  def section({x1, y1}, {x2, y2}) do
    x = section(x1, x2)
    y = section(y1, y2)

    if x && y do
      {x, y}
    end
  end

  def section(a, b) do
    middle = div(b, 2)

    cond do
      a == middle -> nil
      a < middle -> 0
      a > middle -> 1
    end
  end

  def puts_map(positions, {width, height}, sections \\ false) do
    freqs = Enum.frequencies(positions)

    map =
      for y <- 0..(height - 1), x <- 0..width do
        if x == width do
          "\n"
        else
          if sections and (x == div(width, 2) or y == div(height, 2)) do
            " "
          else
            case Map.get(freqs, {x, y}) do
              nil -> "."
              num -> Integer.to_string(num)
            end
          end
        end
      end

    IO.puts(Enum.join(map))

    positions
  end

  def part2(file, size) do
    robots = parse(file)

    Enum.find(0..100_000, fn i ->
      positions =
        Enum.map(robots, fn {pos, vel} ->
          vel |> multiply(i) |> add(pos) |> wrap(size)
        end)

      treeness(positions, size) > length(positions)
    end)
  end

  def treeness(positions, _) do
    set = MapSet.new(positions)

    # increase score with each horizontal, vertical and diagonal neighbour
    Enum.reduce(positions, 0, fn {x, y}, acc ->
      neighbours =
        [{x + 1, y}, {x + 1, y + 1}, {x, y + 1}]
        |> Enum.count(fn neighbour -> MapSet.member?(set, neighbour) end)

      acc + neighbours
    end)
  end
end

Day14.part1("example.txt", {11, 7}) |> IO.inspect(label: "part1 example")
Day14.part1("input.txt", {101, 103}) |> IO.inspect(label: "part1 input")
# Day14.part2("example.txt", {11, 7}) |> IO.inspect(label: "part2 example")
Day14.part2("input.txt", {101, 103}) |> IO.inspect(label: "part2 input")
