defmodule Day9 do
  def parse(file) do
    File.read!(Path.join(Path.dirname(__ENV__.file), file))
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.flat_map(fn {char, index} ->
      length = String.to_integer(char)
      id = if rem(index, 2) == 0, do: div(index, 2), else: -1
      List.duplicate(id, length)
    end)
  end

  def compact(disk) do
    to_move = Enum.reverse(disk) |> Enum.filter(&(&1 != -1))
    total = Enum.count(disk)
    used = Enum.count(to_move)
    unused = total - used
    compact(Enum.slice(disk, 0, used), Enum.slice(to_move, 0, unused))
  end

  def compact([], _), do: []

  def compact([block | rest], to_move) do
    if block == -1 do
      [hd(to_move) | compact(rest, tl(to_move))]
    else
      [block | compact(rest, to_move)]
    end
  end

  def checksum(disk) do
    disk
    |> Enum.with_index()
    |> Enum.reduce(0, fn {id, index}, acc ->
      if id == -1, do: acc, else: acc + id * index
    end)
  end

  def part1(file) do
    parse(file) |> compact() |> checksum()
  end

  # Part 2
  def parse_files(file) do
    File.read!(Path.join(Path.dirname(__ENV__.file), file))
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {char, index} ->
      length = String.to_integer(char)
      id = if rem(index, 2) == 0, do: div(index, 2), else: -1
      {id, length}
    end)
  end

  def compact_files(files) do
    compact_files(files, Enum.reverse(files))
  end

  def compact_files(files, []), do: files

  def compact_files(files, [moving | to_move]) do
    compact_files(move_file(files, moving), to_move)
  end

  def move_file([], _), do: []
  def move_file(files, {movingId, _}) when movingId == -1, do: files

  def move_file([file | files], moving) do
    if file == moving do
      [file | files]
    else
      {fileId, fileLength} = file
      {movingId, movingLength} = moving

      if fileId == -1 and fileLength >= movingLength do
        [moving, {-1, fileLength - movingLength} | remove_file(files, {movingId, movingLength})]
      else
        [file | move_file(files, moving)]
      end
    end
  end

  def remove_file([], _), do: []

  def remove_file([file | files], remove) do
    if file == remove do
      [{-1, elem(remove, 1)} | files]
    else
      [file | remove_file(files, remove)]
    end
  end

  def files_to_disk(files) do
    Enum.flat_map(files, fn {id, length} -> List.duplicate(id, length) end)
  end

  def part2(file) do
    parse_files(file) |> compact_files() |> files_to_disk() |> checksum()
  end
end

Day9.part1("example.txt") |> IO.inspect(label: "part1")
Day9.part1("input.txt") |> IO.inspect(label: "part1")
Day9.part2("example.txt") |> IO.inspect(label: "part2")
Day9.part2("input.txt") |> IO.inspect(label: "part2")
