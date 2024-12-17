defmodule Day17 do
  def parse(file) do
    text = File.read!(Path.join(Path.dirname(__ENV__.file), file))

    for line <- String.split(text, "\n"),
        line !== "",
        into: %{:pointer => 0} do
      case line do
        "Register A: " <> a -> {:a, String.to_integer(a)}
        "Register B: " <> b -> {:b, String.to_integer(b)}
        "Register C: " <> c -> {:c, String.to_integer(c)}
        "Program: " <> p -> {:program, p |> String.split(",") |> Enum.map(&String.to_integer/1)}
      end
    end
  end

  def run(state) do
    Stream.resource(
      fn -> state end,
      fn state ->
        %{:a => a, :b => b, :c => c, :pointer => pointer, :program => program} = state

        state = state |> Map.put(:pointer, pointer + 2)

        case Enum.slice(program, pointer, 2) do
          # adv
          [0, operand] -> {[], Map.put(state, :a, Bitwise.bsr(a, combo(state, operand)))}
          # bxl
          [1, operand] -> {[], Map.put(state, :b, Bitwise.bxor(b, operand))}
          # bst
          [2, operand] -> {[], Map.put(state, :b, Bitwise.band(combo(state, operand), 7))}
          # jnz
          [3, _] when a == 0 -> {[], state}
          [3, operand] -> {[], Map.put(state, :pointer, operand)}
          # bxc
          [4, _] -> {[], Map.put(state, :b, Bitwise.bxor(b, c))}
          # out
          [5, operand] -> {[Bitwise.band(combo(state, operand), 7)], state}
          # bdv
          [6, operand] -> {[], Map.put(state, :b, Bitwise.bsr(a, combo(state, operand)))}
          # cdv
          [7, operand] -> {[], Map.put(state, :c, Bitwise.bsr(a, combo(state, operand)))}
          [] -> {:halt, state}
        end
      end,
      fn _ -> nil end
    )
  end

  def combo(state, operand) do
    case operand do
      4 -> Map.get(state, :a)
      5 -> Map.get(state, :b)
      6 -> Map.get(state, :c)
      _ -> operand
    end
  end

  def part1(file) do
    parse(file) |> run() |> Enum.join(",")
  end

  def part2(file) do
    state = parse(file)
    %{:program => program} = state
    target_length = length(program)

    # each output is produced from XORing the 3-10 least significant bits of A
    # each iteration A is bitshifted right by 3, so bits = length(output) * 3
    # first outputs use least signigicant bits, last outputs use most signigicant bits (and fewer of them)
    # e.g. in output "0,1", 0 is produced from bits 1-6 and 1 is produced from bits 4-6
    # we figure out the bits from left (most significant) by iterating until affected outputs match
    # e.g. xxx000 -> [0]
    # once we have a matching output we can iterate on the next bits
    # e.g. xxxyyy -> [0,1]
    # iterating on different bits each round until the whole output matches
    Enum.reduce((target_length - 1)..0, 0, fn i, a ->
      # check outputs that these bits can affect
      # most signigicant bits
      target = Enum.slice(program, i, target_length - i)

      Stream.unfold(0, fn n -> {n, n + 1} end)
      |> Stream.map(fn n -> n |> Bitwise.bsl(i * 3) |> Bitwise.bor(a) end)
      |> Enum.find(fn a ->
        result = state |> Map.put(:a, a) |> run() |> Enum.slice(i, target_length - i)
        result == target
      end)
    end)
  end
end

Day17.part1("example") |> IO.inspect(label: "part1 example")
Day17.part1("input") |> IO.inspect(label: "part1 input")
Day17.part2("example2") |> IO.inspect(label: "part2 example2")
Day17.part2("input") |> IO.inspect(label: "part2 input")
