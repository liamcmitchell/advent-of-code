defmodule Day16 do
  def parse(file) do
    text = File.read!(Path.join(Path.dirname(__ENV__.file), file))

    for {row, y} <- Enum.with_index(String.split(text, "\n")),
        {char, x} <- Enum.with_index(String.to_charlist(row)),
        char !== ?.,
        into: %{} do
      val =
        case char do
          ?# -> :wall
          ?S -> :start
          ?E -> :end
        end

      {{x, y}, val}
    end
  end

  def part1(file) do
    map = parse(file)
    {start, _} = Enum.find(map, &match?({_, :start}, &1))
    {end_, _} = Enum.find(map, &match?({_, :end}, &1))

    unvisited = MapSet.new([start])
    visited = MapSet.new()
    scores = %{start => {0, {1, 0}}}
    scores = visit(map, unvisited, visited, scores, start)
    scores |> Map.get(end_) |> elem(0)
  end

  def visit(map, unvisited, visited, scores, pos) do
    {score, direction} = Map.get(scores, pos)

    new_scores =
      directions()
      |> Enum.reduce(%{}, fn neighbour_direction, acc ->
        neighbour = add(pos, neighbour_direction)

        cond do
          MapSet.member?(visited, neighbour) ->
            acc

          Map.get(map, neighbour) == :wall ->
            acc

          true ->
            {cur_score, _} = Map.get(scores, neighbour, {999_999, nil})
            new_score = score + if neighbour_direction == direction, do: 1, else: 1001

            if new_score < cur_score do
              Map.put(acc, neighbour, {new_score, neighbour_direction})
            else
              acc
            end
        end
      end)

    visited = MapSet.put(visited, pos)

    unvisited =
      unvisited |> MapSet.delete(pos) |> MapSet.union(new_scores |> Map.keys() |> MapSet.new())

    scores = scores |> Map.merge(new_scores)

    next = unvisited |> Enum.min_by(fn pos -> scores |> Map.get(pos) |> elem(0) end)

    case map do
      %{^next => :end} -> scores
      _ -> visit(map, unvisited, visited, scores, next)
    end
  end

  def directions() do
    [{0, -1}, {0, 1}, {-1, 0}, {1, 0}]
  end

  def add({ax, ay}, {bx, by}) do
    {ax + bx, ay + by}
  end

  def part2(file) do
    map = parse(file)
    {start, _} = Enum.find(map, &match?({_, :start}, &1))
    {end_, _} = Enum.find(map, &match?({_, :end}, &1))

    unvisited = MapSet.new([start])
    visited = MapSet.new()
    scores = %{start => {0, {1, 0}}}
    scores = visit(map, unvisited, visited, scores, start)
    tiles = routes(end_, scores, 0, start, {1, 0}) |> Enum.concat() |> MapSet.new()

    tiles |> MapSet.size()
  end

  def routes(target, scores, cur_score, pos, direction) do
    case scores do
      %{^pos => {score, score_direction}} ->
        if pos == target and score == cur_score do
          [[pos]]
        else
          if cur_score in [score, score + 1000] do
            directions()
            |> Enum.flat_map(fn next ->
              cost = if next !== direction, do: 1001, else: 1
              routes(target, scores, cur_score + cost, add(pos, next), next)
            end)
            |> Enum.map(fn route -> [pos | route] end)
          else
            []
          end
        end

      _ ->
        []
    end
  end
end

Day16.part1("example1") |> IO.inspect(label: "part1 example1")
Day16.part1("example2") |> IO.inspect(label: "part1 example2")
Day16.part1("input") |> IO.inspect(label: "part1 input")
Day16.part2("example1") |> IO.inspect(label: "part2 example1")
Day16.part2("example2") |> IO.inspect(label: "part2 example2")
Day16.part2("input") |> IO.inspect(label: "part2 input")
