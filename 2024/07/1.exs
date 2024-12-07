input = File.read!(Path.join(Path.dirname(__ENV__.file), "input"))

# Part 1
equations =
  for line <- String.split(input, "\n"),
      String.contains?(line, ":"),
      [test_value, operands] = String.split(line, ": ") do
    Enum.map([test_value | String.split(operands, " ")], &String.to_integer/1)
  end

equations
|> Enum.filter(fn [test_value, first | rest] ->
  Enum.any?(0..Integer.pow(2, length(rest)), fn variation ->
    test_value ==
      Enum.reduce(Enum.with_index(rest), first, fn {operand, index}, acc ->
        case Bitwise.band(variation, Bitwise.bsl(1, index)) do
          0 -> acc + operand
          _ -> acc * operand
        end
      end)
  end)
end)
|> Enum.reduce(0, fn [test_value | _], acc -> test_value + acc end)
|> IO.inspect()

# Part 2
equations
|> Enum.filter(fn [test_value, first | rest] ->
  operator_length = length(rest)

  Enum.any?(0..(Integer.pow(3, operator_length) - 1), fn variation ->
    {result, _} =
      Enum.reduce(Enum.with_index(rest), {first, 0}, fn {operand, index}, {result, tested} ->
        part = Integer.pow(3, operator_length - index - 1)
        parts = floor((variation - tested) / part)

        result =
          case parts do
            0 -> result + operand
            1 -> result * operand
            2 -> String.to_integer(Integer.to_string(result) <> Integer.to_string(operand))
          end

        {result, tested + part * parts}
      end)

    test_value == result
  end)
end)
|> Enum.reduce(0, fn [test_value | _], acc -> test_value + acc end)
|> IO.inspect()
