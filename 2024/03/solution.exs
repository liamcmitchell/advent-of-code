input = File.read!("2024/03/input.txt")

# Part 1
Regex.scan(~r/mul\((\d{1,3}),(\d{1,3})\)/, input)
|> Enum.reduce(0, fn result, acc ->
  [_, a, b] = result
  acc + String.to_integer(a) * String.to_integer(b)
end)
|> IO.inspect()

# Part 2
Regex.scan(~r/mul\((\d{1,3}),(\d{1,3})\)|do\(\)|don't\(\)/, input)
|> Enum.reduce({true, 0}, fn result, {enabled, sum} ->
  case result do
    [do_or_dont] -> {do_or_dont == "do()", sum}
    [_, a, b] when enabled -> {enabled, sum + String.to_integer(a) * String.to_integer(b)}
    _ -> {enabled, sum}
  end
end)
|> elem(1)
|> IO.inspect()
