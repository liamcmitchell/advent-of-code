const std = @import("std");

const Galaxy = struct {
    row: usize,
    col: usize,
};

fn absDiff(a: usize, b: usize) usize {
    return @intCast(@as(isize, @intCast(@max(a, b))) - @as(isize, @intCast(@min(a, b))));
}

fn solve(allocator: std.mem.Allocator, input: []const u8, expansion: usize) !usize {
    const size = std.math.sqrt(input.len) + 10;
    var galaxies = try std.ArrayList(Galaxy).initCapacity(allocator, size);
    var filledRows = try allocator.alloc(bool, size);
    var filledCols = try allocator.alloc(bool, size);
    var row: usize = 0;
    var col: usize = 0;
    for (input) |char| {
        if (char == '#') {
            try galaxies.append(Galaxy{ .row = (row), .col = col });
            filledRows[row] = true;
            filledCols[col] = true;
        }
        if (char == '\n') {
            col = 0;
            row += 1;
        } else {
            col += 1;
        }
    }

    var emptyRows = try allocator.alloc(usize, size);
    var emptyCount: usize = 0;
    row = 0;
    for (filledRows) |filled| {
        if (!filled) {
            emptyCount += 1;
        }
        emptyRows[row] = emptyCount;
        row += 1;
    }

    var emptyCols = try allocator.alloc(usize, size);
    emptyCount = 0;
    col = 0;
    for (filledCols) |filled| {
        if (!filled) {
            emptyCount += 1;
        }
        emptyCols[col] = emptyCount;
        col += 1;
    }

    var total: usize = 0;
    for (galaxies.items[0 .. galaxies.items.len - 1], 0..) |a, ai| {
        for (galaxies.items[ai + 1 .. galaxies.items.len]) |b| {
            const rowDiff = absDiff(a.row, b.row);
            const colDiff = absDiff(a.col, b.col);
            const rowExpansion = absDiff(emptyRows[a.row], emptyRows[b.row]);
            const colExpansion = absDiff(emptyCols[a.col], emptyCols[b.col]);
            total += rowDiff + colDiff + (rowExpansion + colExpansion) * expansion;
        }
    }

    return total;
}

fn part1(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    const total = try solve(allocator, input, 1);

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

fn part2(name: []const u8, expansion: usize) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    const total = try solve(allocator, input, expansion - 1);

    std.debug.print("Part 2 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/11/example.txt");
    try part1("2023/11/input.txt");
    try part2("2023/11/example.txt", 10);
    try part2("2023/11/example.txt", 100);
    try part2("2023/11/input.txt", 1000000);
}
