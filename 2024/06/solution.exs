input = File.read!(Path.join(Path.dirname(__ENV__.file), "input.txt"))

# Part 1
defmodule Guard do
  def index_position(index, width) do
    row = floor(index / (width + 1))
    col = index - row * (width + 1)
    {row, col}
  end

  def step(width, height, obstacles, position, direction, visited \\ MapSet.new()) do
    {p_row, p_col} = position
    {d_row, d_col} = direction

    if p_row >= 0 and p_row < height and p_col >= 0 and p_col < width do
      next_position = {p_row + d_row, p_col + d_col}

      if MapSet.member?(obstacles, next_position) do
        step(width, height, obstacles, position, {d_col, -d_row}, visited)
      else
        step(width, height, obstacles, next_position, direction, MapSet.put(visited, position))
      end
    else
      visited
    end
  end

  # Added in Part2
  def loops?(width, height, obstacles, position, direction, visited \\ MapSet.new()) do
    {p_row, p_col} = position
    {d_row, d_col} = direction

    if p_row >= 0 and p_row < height and p_col >= 0 and p_col < width do
      next_position = {p_row + d_row, p_col + d_col}

      if MapSet.member?(obstacles, next_position) do
        loops?(width, height, obstacles, position, {d_col, -d_row}, visited)
      else
        visit = {position, direction}

        if MapSet.member?(visited, visit) do
          true
        else
          loops?(
            width,
            height,
            obstacles,
            next_position,
            direction,
            MapSet.put(visited, visit)
          )
        end
      end
    else
      false
    end
  end
end

[{width, _}] = Regex.run(~r/\n/, input, return: :index)
height = ceil(String.length(input) / (width + 1))

obstacles =
  Regex.scan(~r/#/, input, return: :index)
  |> Enum.map(fn [{index, _}] ->
    Guard.index_position(index, width)
  end)
  |> MapSet.new()

[position] =
  Regex.scan(~r/\^/, input, return: :index)
  |> Enum.map(fn [{index, _}] ->
    Guard.index_position(index, width)
  end)

direction = {-1, 0}

visited = Guard.step(width, height, obstacles, position, direction)

IO.inspect(Enum.count(visited))

# Part 2
visited
|> MapSet.delete(position)
|> Enum.filter(fn obstruction ->
  Guard.loops?(width, height, MapSet.put(obstacles, obstruction), position, direction)
end)
|> Enum.count()
|> IO.inspect()
