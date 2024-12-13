defmodule Day13 do
  def parse(file) do
    text = File.read!(Path.join(Path.dirname(__ENV__.file), file))

    Regex.scan(
      ~r/Button A: X([+-]\d+), Y([+-]\d+)\nButton B: X([+-]\d+), Y([+-]\d+)\nPrize: X=(\d+), Y=(\d+)/,
      text
    )
    |> Enum.map(fn [_match | groups] ->
      [ax, ay, bx, by, px, py] = Enum.map(groups, &String.to_integer/1)
      {{ax, ay}, {bx, by}, {px, py}}
    end)
  end

  def add({x1, y1}, {x2, y2}) do
    {x1 + x2, y1 + y2}
  end

  def subtract({x1, y1}, {x2, y2}) do
    {x1 - x2, y1 - y2}
  end

  def divide({x1, y1}, {x2, y2}) do
    if rem(x1, x2) == 0 and rem(y1, y2) == 0 do
      x = div(x1, x2)
      y = div(y1, y2)

      if x == y do
        x
      end
    end
  end

  def intersection({x1, y1}, {x2, y2}, {x3, y3}, {x4, y4}) do
    denominator = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)

    if denominator != 0 do
      x_n = (x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)
      y_n = (x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)

      if rem(x_n, denominator) == 0 and rem(y_n, denominator) == 0 do
        {div(x_n, denominator), div(y_n, denominator)}
      end
    end
  end

  def cost({a, b, p}) do
    if intersection = intersection({0, 0}, a, p, add(p, b)) do
      a_times = divide(intersection, a)
      b_times = divide(subtract(p, intersection), b)

      if a_times && b_times do
        a_times * 3 + b_times
      end
    end
  end

  def part1(file) do
    parse(file)
    |> Enum.map(&cost/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.sum()
  end

  def correct({a, b, p}) do
    {a, b, add(p, {10_000_000_000_000, 10_000_000_000_000})}
  end

  def part2(file) do
    parse(file)
    |> Enum.map(&correct/1)
    |> Enum.map(&cost/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.sum()
  end
end

Day13.part1("example") |> IO.inspect(label: "part1 example")
Day13.part1("input") |> IO.inspect(label: "part1 input")
Day13.part2("example") |> IO.inspect(label: "part2 example")
Day13.part2("input") |> IO.inspect(label: "part2 input")
