defmodule Day15 do
  def parse(file) do
    text = File.read!(Path.join(Path.dirname(__ENV__.file), file))
    [map, directions] = String.split(text, "\n\n")

    map =
      for {row, y} <- Enum.with_index(String.split(map, "\n")),
          {char, x} <- Enum.with_index(String.to_charlist(row)),
          char !== ?.,
          into: %{} do
        val =
          case char do
            ?# -> :wall
            ?O -> :box
            ?@ -> :robot
          end

        {{x, y}, val}
      end

    directions =
      for <<char <- directions>>, char !== ?\n do
        case char do
          ?< -> {-1, 0}
          ?^ -> {0, -1}
          ?> -> {1, 0}
          ?v -> {0, 1}
        end
      end

    {map, directions}
  end

  def part1(file) do
    {map, directions} = parse(file)

    map
    |> execute(directions)
    |> Enum.filter(&match?({_, :box}, &1))
    |> Enum.map(fn {{x, y}, _} -> x + y * 100 end)
    |> Enum.sum()
  end

  def part2(file) do
    {map, directions} = parse(file)

    map
    |> widen()
    |> execute(directions)
    |> Enum.filter(&match?({_, :boxl}, &1))
    |> Enum.map(fn {{x, y}, _} -> x + y * 100 end)
    |> Enum.sum()
  end

  def execute(map, directions) do
    {pos, _} = Enum.find(map, &match?({_, :robot}, &1))

    directions
    |> Enum.reduce({pos, map}, fn direction, {pos, map} ->
      case movable(map, pos, direction) do
        nil ->
          {pos, map}

        positions ->
          {add(pos, direction), move(map, positions, direction)}
      end
    end)
    |> elem(1)
  end

  def widen(map) do
    map
    |> Enum.flat_map(fn {{x, y}, object} ->
      case object do
        :robot ->
          [{{x * 2, y}, :robot}]

        :box ->
          [
            {{x * 2, y}, :boxl},
            {{x * 2 + 1, y}, :boxr}
          ]

        :wall ->
          [
            {{x * 2, y}, :wall},
            {{x * 2 + 1, y}, :wall}
          ]
      end
    end)
    |> Map.new()
  end

  def add({x1, y1}, {x2, y2}) do
    {x1 + x2, y1 + y2}
  end

  def move(map, positions, direction) do
    moved =
      positions
      |> Enum.map(fn pos -> {add(pos, direction), Map.get(map, pos)} end)
      |> Map.new()

    map |> Map.drop(positions) |> Map.merge(moved)
  end

  def movable(map, pos, direction) do
    case Map.get(map, pos) do
      :wall ->
        nil

      nil ->
        []

      box1
      when (box1 == :boxl or box1 == :boxr) and (direction == {0, 1} or direction == {0, -1}) ->
        pos2 = if box1 == :boxr, do: add(pos, {-1, 0}), else: add(pos, {1, 0})

        case {movable(map, add(pos, direction), direction),
              movable(map, add(pos2, direction), direction)} do
          {nil, _} -> nil
          {_, nil} -> nil
          {p1, p2} -> [pos, pos2 | p1] ++ p2
        end

      _ ->
        case movable(map, add(pos, direction), direction) do
          nil -> nil
          positions -> [pos | positions]
        end
    end
  end
end

Day15.part1("example1.txt") |> IO.inspect(label: "part1 example1")
Day15.part1("example2.txt") |> IO.inspect(label: "part1 example2")
Day15.part1("input.txt") |> IO.inspect(label: "part1 input")
Day15.part2("example1.txt") |> IO.inspect(label: "part2 example1")
Day15.part2("input.txt") |> IO.inspect(label: "part2 input")
