defmodule Day22 do
  import Bitwise

  def parse(file) do
    text = File.read!(Path.join(Path.dirname(__ENV__.file), file))

    text
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  def solve(numbers, n) do
    numbers
    |> Enum.map(fn number ->
      1..n
      |> Enum.reduce(number, fn _, number ->
        next(number)
      end)
    end)
    |> Enum.sum()
  end

  def next(number) do
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

  def price(number) do
    number |> Integer.digits() |> Enum.at(-1)
  end

  def part(1, file) do
    file
    |> parse()
    |> Enum.map(fn number ->
      1..2000
      |> Enum.reduce(number, fn _, number ->
        next(number)
      end)
    end)
    |> Enum.sum()
  end

  def part(2, file) do
    file
    |> parse()
    |> Enum.map(fn number ->
      1..2000
      |> Enum.reduce({%{}, number, price(number), []}, fn _,
                                                          {prices, number, prev_price,
                                                           price_changes} ->
        number = number |> next()
        price = number |> price()
        price_change = price - prev_price
        price_changes = [price_change | price_changes]
        sequence = price_changes |> Enum.slice(0, 4)

        prices =
          if length(sequence) == 4 do
            prices |> Map.put_new(sequence, price)
          else
            prices
          end

        {prices, number, price, price_changes}
      end)
      |> elem(0)
      |> Enum.to_list()
    end)
    |> Enum.concat()
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Enum.map(&elem(&1, 1))
    |> Enum.map(&Enum.sum/1)
    |> Enum.max()
  end

  def run(part, input) do
    {time, value} = :timer.tc(&part/2, [part, input])
    time = :erlang.float_to_binary(time / 1000, decimals: 1)

    IO.inspect(value, label: "Part #{part} #{input} (#{time}ms)", charlists: :as_lists)
  end
end

Day22.run(1, "example")
Day22.run(1, "input")
Day22.run(2, "example2")
Day22.run(2, "input")
