defmodule Day11 do
  def parse(file) do
    File.read!(Path.join(Path.dirname(__ENV__.file), file))
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  def blink(_stone, 0), do: 1
  def blink(0, remaining), do: blink(1, remaining - 1)

  def blink(stone, remaining) do
    key = {stone, remaining}

    with nil <- Process.get(key) do
      blink(stone)
      |> Enum.map(&blink(&1, remaining - 1))
      |> Enum.sum()
      |> tap(&Process.put(key, &1))
    end
  end

  def blink(0), do: [1]

  def blink(stone) do
    key = stone

    with nil <- Process.get(key) do
      digits = Integer.to_string(stone)
      length = String.length(digits)

      if rem(length, 2) == 0 do
        {left, right} = String.split_at(digits, div(length, 2))
        [String.to_integer(left), String.to_integer(right)]
      else
        [stone * 2024]
      end
      |> tap(&Process.put(key, &1))
    end
  end

  def part1(file) do
    parse(file) |> Enum.map(&blink(&1, 25)) |> Enum.sum()
  end

  def part2(file) do
    parse(file) |> Enum.map(&blink(&1, 75)) |> Enum.sum()
  end
end

Day11.part1("example") |> IO.inspect(label: "part1")
Day11.part1("input") |> IO.inspect(label: "part1")
Day11.part2("example") |> IO.inspect(label: "part2")
Day11.part2("input") |> IO.inspect(label: "part2")
