defmodule Day25 do
  def parse(file) do
    text = File.read!(Path.join(Path.dirname(__ENV__.file), file))

    text
    |> String.split("\n\n")
    |> Enum.reduce({[], []}, fn block, {locks, keys} ->
      is_lock = block |> String.first() == "#"

      heights =
        block
        |> String.codepoints()
        |> Enum.filter(&(&1 in ["#", "."]))
        |> Enum.map(fn char ->
          case char do
            "#" ->
              1

            "." ->
              0
          end
        end)
        |> Integer.undigits(2)

      if is_lock do
        {[heights | locks], keys}
      else
        {locks, [heights | keys]}
      end
    end)
  end

  def part(1, file) do
    {locks, keys} = file |> parse()

    locks
    |> Enum.map(fn lock ->
      keys |> Enum.count(fn key -> Bitwise.band(lock, key) == 0 end)
    end)
    |> Enum.sum()
  end

  def run(part, input) do
    {time, value} = :timer.tc(&part/2, [part, input])
    time = :erlang.float_to_binary(time / 1000, decimals: 1)

    IO.inspect(value, label: "Part #{part} #{input} (#{time}ms)", charlists: :as_lists)
  end
end

Day25.run(1, "example.txt")
Day25.run(1, "input.txt")
# Woooooooo!
