const std = @import("std");

fn part1(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var total: usize = 0;

    var patternIt = std.mem.tokenizeSequence(u8, input, "\n\n");
    while (patternIt.next()) |pattern| {
        const width = std.mem.indexOfScalar(u8, pattern, '\n').?;
        const height = (pattern.len + 1) / (width + 1);

        vertical: for (1..(width)) |reflectionCol| {
            for (0..@min(reflectionCol, width - reflectionCol)) |offset| {
                const leftCol = reflectionCol - 1 - offset;
                const rightCol = reflectionCol + offset;
                for (0..height) |row| {
                    const rowIndex = row * (width + 1);
                    if (pattern[rowIndex + leftCol] != pattern[rowIndex + rightCol]) {
                        continue :vertical;
                    }
                }
            }
            total += reflectionCol;
        }

        horizontal: for (1..(height)) |reflectionRow| {
            for (0..@min(reflectionRow, height - reflectionRow)) |offset| {
                const topRow = (reflectionRow - 1 - offset) * (width + 1);
                const bottomRow = (reflectionRow + offset) * (width + 1);
                for (0..width) |col| {
                    if (pattern[topRow + col] != pattern[bottomRow + col]) {
                        continue :horizontal;
                    }
                }
            }
            total += reflectionRow * 100;
        }
    }

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

fn part2(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var total: usize = 0;

    var patternIt = std.mem.tokenizeSequence(u8, input, "\n\n");
    while (patternIt.next()) |pattern| {
        const width = std.mem.indexOfScalar(u8, pattern, '\n').?;
        const height = (pattern.len + 1) / (width + 1);

        vertical: for (1..(width)) |reflectionCol| {
            var smudged = false;
            for (0..@min(reflectionCol, width - reflectionCol)) |offset| {
                const leftCol = reflectionCol - 1 - offset;
                const rightCol = reflectionCol + offset;
                for (0..height) |row| {
                    const rowIndex = row * (width + 1);
                    if (pattern[rowIndex + leftCol] != pattern[rowIndex + rightCol]) {
                        if (smudged) {
                            continue :vertical;
                        } else {
                            smudged = true;
                        }
                    }
                }
            }
            if (smudged) {
                total += reflectionCol;
            }
        }

        horizontal: for (1..(height)) |reflectionRow| {
            var smudged = false;
            for (0..@min(reflectionRow, height - reflectionRow)) |offset| {
                const topRow = (reflectionRow - 1 - offset) * (width + 1);
                const bottomRow = (reflectionRow + offset) * (width + 1);
                for (0..width) |col| {
                    if (pattern[topRow + col] != pattern[bottomRow + col]) {
                        if (smudged) {
                            continue :horizontal;
                        } else {
                            smudged = true;
                        }
                    }
                }
            }
            if (smudged) {
                total += reflectionRow * 100;
            }
        }
    }

    std.debug.print("Part 2 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/13/example.txt");
    try part1("2023/13/input.txt");
    try part2("2023/13/example.txt");
    try part2("2023/13/input.txt");
}
