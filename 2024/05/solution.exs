input = File.read!(Path.join(Path.dirname(__ENV__.file), "input.txt"))

# Part 1
[rules, manuals] = String.split(input, "\n\n")

rules =
  rules
  |> String.split("\n")
  |> Enum.reduce(%{}, fn line, acc ->
    [left, right] = String.split(line, "|")
    left = String.to_integer(left)
    right = String.to_integer(right)

    %{:before => beforeLeft, :after => afterLeft} =
      Map.get(acc, left, %{:before => MapSet.new(), :after => MapSet.new()})

    %{:before => beforeRight, :after => afterRight} =
      Map.get(acc, right, %{:before => MapSet.new(), :after => MapSet.new()})

    acc = Map.put(acc, left, %{:before => beforeLeft, :after => MapSet.put(afterLeft, right)})
    acc = Map.put(acc, right, %{:before => MapSet.put(beforeRight, left), :after => afterRight})
    acc
  end)

manuals =
  for line <- String.split(manuals, "\n") do
    for page <- String.split(line, ",") do
      String.to_integer(page)
    end
  end

manuals
|> Enum.filter(fn manual ->
  Enum.reduce(manual, {true, MapSet.new()}, fn page, {correct, before} ->
    if !correct do
      {correct, before}
    else
      {MapSet.subset?(before, get_in(rules, [page, :before])), MapSet.put(before, page)}
    end
  end)
  |> elem(0)
end)
|> Enum.map(fn manual ->
  Enum.at(manual, floor(length(manual) / 2))
end)
|> Enum.reduce(&+/2)
|> IO.inspect()

# Part 2
manuals
|> Enum.reject(fn manual ->
  Enum.reduce(manual, {true, MapSet.new()}, fn page, {correct, before} ->
    if !correct do
      {correct, before}
    else
      {MapSet.subset?(before, get_in(rules, [page, :before])), MapSet.put(before, page)}
    end
  end)
  |> elem(0)
end)
|> Enum.map(fn manual ->
  Enum.sort(manual, fn a, b ->
    MapSet.member?(get_in(rules, [a, :before]), b)
  end)
end)
|> Enum.map(fn manual ->
  Enum.at(manual, floor(length(manual) / 2))
end)
|> Enum.reduce(&+/2)
|> IO.inspect()
