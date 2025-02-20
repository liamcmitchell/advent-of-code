const std = @import("std");

const Dir = enum {
    up,
    right,
    down,
    left,
};

const Pos = struct {
    x: isize,
    y: isize,

    pub fn init(x: anytype, y: anytype) Pos {
        return Pos{ .x = @intCast(x), .y = @intCast(y) };
    }
};

fn part1(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var total: isize = 0;
    var pos = Pos.init(0, 0);
    var lineIt = std.mem.tokenizeScalar(u8, input, '\n');
    while (lineIt.next()) |line| {
        const last = pos;
        var partIt = std.mem.tokenizeScalar(u8, line, ' ');
        const dir = partIt.next().?[0];
        const meters = try std.fmt.parseInt(u4, partIt.next().?, 10);
        switch (dir) {
            'U' => pos.y -= meters,
            'R' => pos.x += meters,
            'D' => pos.y += meters,
            'L' => pos.x -= meters,
            else => unreachable,
        }
        total += (last.x * pos.y) - (last.y * pos.x) + meters;
    }
    total = @divTrunc(total, 2) + 1;

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

fn part2(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var total: isize = 0;
    var pos = Pos.init(0, 0);
    var lineIt = std.mem.tokenizeScalar(u8, input, '\n');
    while (lineIt.next()) |line| {
        const last = pos;
        var partIt = std.mem.tokenizeScalar(u8, line, ' ');
        _ = partIt.next();
        _ = partIt.next();
        const hex = partIt.next().?;
        const meters = try std.fmt.parseInt(u32, hex[2..7], 16);
        switch (hex[7]) {
            '0' => pos.x += meters,
            '1' => pos.y += meters,
            '2' => pos.x -= meters,
            '3' => pos.y -= meters,
            else => unreachable,
        }
        total += (last.x * pos.y) - (last.y * pos.x) + meters;
    }
    total = @divTrunc(total, 2) + 1;

    std.debug.print("Part 2 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/18/example.txt");
    try part1("2023/18/input.txt");
    try part2("2023/18/example.txt");
    try part2("2023/18/input.txt");
}
