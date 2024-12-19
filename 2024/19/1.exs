defmodule Day19 do
  def parse(file) do
    text = File.read!(Path.join(Path.dirname(__ENV__.file), file))
    [towels, _ | patterns] = String.split(text, "\n")
    towels = towels |> String.split(", ")

    {towels, patterns}
  end

  def part1(file) do
    {towels, patterns} = parse(file)
    tree = towel_tree(towels)

    patterns
    |> Enum.count(&(possibilities(&1, tree) > 0))
  end

  def part2(file) do
    {towels, patterns} = parse(file)
    tree = towel_tree(towels)

    patterns
    |> Enum.map(&possibilities(&1, tree))
    |> Enum.sum()
  end

  def towel_tree(towels) do
    towels
    |> Enum.reduce(%{}, fn towel, tree ->
      towel_tree(tree, String.codepoints(towel))
    end)
  end

  def towel_tree(tree, []) do
    tree |> Map.put(:end, :end)
  end

  def towel_tree(tree, [color | rest]) do
    tree
    |> Map.put_new(color, %{})
    |> Map.update!(color, &towel_tree(&1, rest))
  end

  def possibilities(pattern, tree) do
    pattern
    |> String.codepoints()
    |> Enum.reduce([{1, %{:end => :end}}], fn color, permutations ->
      new = {completed(permutations), Map.get(tree, color)}
      [new | next(permutations, color)]
    end)
    |> completed()
  end

  def completed(permutations) do
    permutations
    |> Enum.flat_map(fn {times, branch} ->
      case branch do
        %{:end => :end} -> [times]
        _ -> []
      end
    end)
    |> Enum.sum()
  end

  def next(permutations, color) do
    permutations
    |> Enum.flat_map(fn {times, branch} ->
      case branch do
        %{^color => branch} -> [{times, branch}]
        _ -> []
      end
    end)
  end
end

Day19.part1("example") |> IO.inspect(label: "part1 example")
Day19.part1("input") |> IO.inspect(label: "part1 input")
Day19.part2("example") |> IO.inspect(label: "part2 example")
Day19.part2("input") |> IO.inspect(label: "part2 input")
