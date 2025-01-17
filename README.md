https://adventofcode.com/

The AoC author [doesn't want](https://adventofcode.com/about) puzzle text or inputs copied so input `*.txt` files are not committed. To run this locally you would have to reproduce these files yourself.

All solutions are single files without external dependencies and should be executable with the following commmands:

```bash
# Elixir
elixir 2024/01/solution.exs
# Go
go run 2023/01/solution.go
# Zig
zig run 2023/01/solution.zig
```

I use [fswatch](https://github.com/emcrisostomo/fswatch?tab=readme-ov-file#readme) for a simple save-execute workflow:

```bash
fswatch **/*.go | xargs -n1 -I{} go run {}
```
