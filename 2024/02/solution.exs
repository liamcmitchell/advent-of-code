reports =
  "2024/02/input.txt"
  |> File.read!()
  |> String.split("\n")
  |> Enum.map(fn line ->
    line
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end)

# Part 1
report_diffs =
  reports
  |> Enum.map(fn report ->
    report
    |> Enum.reduce(fn level, acc ->
      {prev, diffs} =
        case acc do
          prev when is_integer(prev) -> {prev, []}
          x -> x
        end

      {level, [level - prev | diffs]}
    end)
    |> elem(1)
  end)

safe_report_count =
  report_diffs
  |> Enum.count(fn diffs ->
    Enum.all?(diffs, fn diff -> abs(diff) < 4 end) &&
      (Enum.all?(diffs, fn diff -> diff < 0 end) || Enum.all?(diffs, fn diff -> diff > 0 end))
  end)

# Part 2
defmodule Report do
  def unsafe_levels(report, ignore \\ -1) do
    Enum.reduce(report, {0, nil, nil, []}, fn level, acc ->
      {i, prev, direction, unsafe} = acc

      if ignore == i do
        {i + 1, prev, direction, unsafe}
      else
        if prev == nil do
          {i + 1, level, direction, unsafe}
        else
          diff = level - prev
          this_direction = diff > 0
          direction = if is_nil(direction), do: this_direction, else: direction
          is_safe = this_direction == direction && abs(diff) > 0 && abs(diff) < 4
          unsafe = if is_safe, do: unsafe, else: [i | unsafe]
          {i + 1, level, direction, unsafe}
        end
      end
    end)
    |> elem(3)
  end

  def is_safe?(report) do
    case Report.unsafe_levels(report) do
      [] ->
        true

      # Brute force used to figure out missing cases in optimized cases below:
      # _ ->
      #   Enum.any?(0..(length(report) - 1), fn ignore ->
      #     Enum.empty?(Report.unsafe_levels(report, ignore))
      #   end)

      [i] ->
        Enum.empty?(Report.unsafe_levels(report, i - 1)) ||
          Enum.empty?(Report.unsafe_levels(report, i))

      [i, j] ->
        i - j == 1 && Enum.empty?(Report.unsafe_levels(report, j))

      _ ->
        Enum.empty?(Report.unsafe_levels(report, 0)) ||
          Enum.empty?(Report.unsafe_levels(report, 1))
    end
  end
end

# IO.puts(Enum.count(reports, &Report.is_safe?/1))
