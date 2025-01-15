sorted_lists =
  "2024/01/input.txt"
  |> File.read!()
  |> String.split()
  |> Enum.map(&String.to_integer/1)
  |> Enum.chunk_every(2)
  |> Enum.map(&List.to_tuple/1)
  |> Enum.unzip()
  |> Tuple.to_list()
  |> Enum.map(&Enum.sort/1)

# First part
sorted_lists
|> Enum.zip()
|> Enum.map(fn {a, b} -> abs(a - b) end)
|> Enum.reduce(&+/2)
|> IO.puts()

# Second part
[left, right] = sorted_lists
frequencies = Enum.frequencies(right)

left
|> Enum.reduce(0, fn id, acc -> acc + id * (Map.get(frequencies, id) || 0) end)
|> IO.puts()
