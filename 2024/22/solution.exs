defmodule Day22 do
  def parse(file) do
    text = File.read!(Path.join(Path.dirname(__ENV__.file), file))

    text
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  def next(number) do
    import Bitwise

    number =
      number
      |> bsl(6)
      |> bxor(number)
      |> band(16_777_215)

    number =
      number
      |> bsr(5)
      |> bxor(number)
      |> band(16_777_215)

    number =
      number
      |> bsl(11)
      |> bxor(number)
      |> band(16_777_215)

    number
  end

  def price(number), do: number |> rem(10)

  def part(1, file) do
    file
    |> parse()
    |> Enum.map(fn number ->
      1..2000
      |> Enum.reduce(number, fn _, n -> next(n) end)
    end)
    |> Enum.sum()
  end

  def part(2, file) do
    file
    |> parse()
    |> Enum.reduce(%{}, fn number, sales ->
      1..2000
      |> Enum.reduce({sales, MapSet.new(), number, price(number), nil, nil, nil}, fn _, acc ->
        {sales, seen, number, prev_price, pc1, pc2, pc3} = acc
        number = number |> next()
        price = number |> price()
        pc0 = price - prev_price

        with false <- pc3 == nil,
             <<sequence::integer-20>> <- <<pc0::5, pc1::5, pc2::5, pc3::5>>,
             false <- MapSet.member?(seen, sequence) do
          seen = MapSet.put(seen, sequence)
          sales = Map.update(sales, sequence, price, &(&1 + price))
          {sales, seen, number, price, pc0, pc1, pc2}
        else
          _ ->
            {sales, seen, number, price, pc0, pc1, pc2}
        end
      end)
      |> elem(0)
    end)
    |> Map.values()
    |> Enum.max()
  end

  def run(part, input) do
    {time, value} = :timer.tc(&part/2, [part, input])
    time = :erlang.float_to_binary(time / 1000, decimals: 1)

    IO.inspect(value, label: "Part #{part} #{input} (#{time}ms)", charlists: :as_lists)
  end
end

Day22.run(1, "example.txt")
Day22.run(1, "input.txt")
Day22.run(2, "example2.txt")
Day22.run(2, "input.txt")
