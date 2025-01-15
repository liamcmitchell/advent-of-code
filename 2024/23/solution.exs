defmodule Day23 do
  def parse(file) do
    text = File.read!(Path.join(Path.dirname(__ENV__.file), file))

    text
    |> String.split()
    |> Enum.map(&String.split(&1, "-"))
  end

  def map(pairs) do
    pairs
    |> Enum.reduce(%{}, fn [a, b], map ->
      map
      |> Map.update(a, MapSet.new([b]), &MapSet.put(&1, b))
      |> Map.update(b, MapSet.new([a]), &MapSet.put(&1, a))
    end)
  end

  def part(1, file) do
    map = file |> parse() |> map()

    map
    |> Enum.flat_map(fn {a, bs} ->
      if String.starts_with?(a, "t") do
        bs
        |> Enum.flat_map(fn b ->
          map
          |> Map.get(b)
          |> Enum.flat_map(fn c ->
            if MapSet.member?(Map.get(map, c), a) do
              [MapSet.new([a, b, c])]
            else
              []
            end
          end)
        end)
      else
        []
      end
    end)
    |> Enum.uniq()
    |> Enum.count()
  end

  def part(2, file) do
    map = file |> parse() |> map()

    map
    |> Enum.map(fn {a, a_links} ->
      a_links
      |> Enum.map(fn b ->
        map |> Map.get(b) |> MapSet.intersection(a_links)
      end)
      |> Enum.concat()
      |> Enum.frequencies()
      |> Enum.sort_by(&elem(&1, 1), :desc)
      |> Enum.reduce(MapSet.new([a]), fn {node, _}, group ->
        if MapSet.subset?(group, Map.get(map, node)) do
          MapSet.put(group, node)
        else
          group
        end
      end)
    end)
    |> Enum.max_by(&MapSet.size/1)
    |> Enum.sort()
    |> Enum.join(",")
  end

  def run(part, input) do
    {time, value} = :timer.tc(&part/2, [part, input])
    time = :erlang.float_to_binary(time / 1000, decimals: 1)

    IO.inspect(value, label: "Part #{part} #{input} (#{time}ms)", charlists: :as_lists)
  end
end

Day23.run(1, "example.txt")
Day23.run(1, "input.txt")
Day23.run(2, "example.txt")
Day23.run(2, "input.txt")
