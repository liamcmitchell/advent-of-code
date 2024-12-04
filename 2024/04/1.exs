input = File.read!("2024/04/input")

# Part 1
horizontal = String.split(input, "\n")
rows = length(horizontal)
columns = String.length(hd(horizontal))
diagonals = rows + columns - 1

vertical =
  Enum.reduce(horizontal, List.duplicate("", columns), fn line, acc ->
    Enum.zip_with(String.codepoints(line), acc, fn current, prev -> prev <> current end)
  end)

diagonalLeft =
  Enum.reduce(Enum.with_index(horizontal), List.duplicate("", diagonals), fn {line, row}, acc ->
    Enum.zip_with(
      List.duplicate(" ", row) ++ String.codepoints(line) ++ List.duplicate(" ", columns),
      acc,
      fn current, prev -> prev <> current end
    )
  end)

diagonalRight =
  Enum.reduce(Enum.with_index(horizontal), List.duplicate("", diagonals), fn {line, row}, acc ->
    Enum.zip_with(
      List.duplicate(" ", rows - 1 - row) ++
        String.codepoints(line) ++ List.duplicate(" ", columns),
      acc,
      fn current, prev -> prev <> current end
    )
  end)

Enum.reduce(horizontal ++ vertical ++ diagonalLeft ++ diagonalRight, 0, fn line, acc ->
  acc + length(Regex.scan(~r/XMAS/, line)) + length(Regex.scan(~r/XMAS/, String.reverse(line)))
end)
|> IO.inspect()

# Part 2
defmodule Mas do
  def centers(line) do
    Enum.map(
      Enum.concat(
        Regex.scan(~r/MAS/, line, return: :index) ++ Regex.scan(~r/SAM/, line, return: :index)
      ),
      fn {index, _} ->
        index + 1
      end
    )
  end
end

masesLeft =
  diagonalLeft
  |> Enum.with_index(fn line, col ->
    Enum.map(
      Mas.centers(line),
      fn row ->
        {row, col - row}
      end
    )
  end)
  |> Enum.concat()

masesRight =
  diagonalRight
  |> Enum.with_index(fn line, col ->
    Enum.map(
      Mas.centers(line),
      fn row ->
        {row, col - (rows - 1 - row)}
      end
    )
  end)
  |> Enum.concat()

MapSet.intersection(MapSet.new(masesLeft), MapSet.new(masesRight))
|> Enum.count()
|> IO.inspect()
