const std = @import("std");

fn part1(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var total: u32 = 0;
    var first: u8 = 0;
    var firstFound: bool = false;
    var last: u8 = 0;
    for (input) |char| {
        if (char >= '0' and char <= '9') {
            if (!firstFound) {
                firstFound = true;
                first = char - '0';
            }
            last = char - '0';
        }
        if (char == '\n') {
            total += first * 10 + last;
            firstFound = false;
        }
    }
    total += first * 10 + last;

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

fn part2(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    const words = [_][]const u8{ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

    var lines = std.mem.splitSequence(u8, input, "\n");
    var total: usize = 0;
    while (lines.next()) |line| {
        var first: usize = 0;
        var firstIdx: usize = line.len;
        var last: usize = 0;
        var lastIdx: usize = 0;
        for (words, 0..) |word, idx| {
            const firstWordIdx = std.mem.indexOf(u8, line, word);
            if (firstWordIdx != null and firstWordIdx.? <= firstIdx) {
                first = idx % 10;
                firstIdx = firstWordIdx.?;
            }
            const lastWordIdx = std.mem.lastIndexOf(u8, line, word);
            if (lastWordIdx != null and lastWordIdx.? >= lastIdx) {
                last = idx % 10;
                lastIdx = lastWordIdx.?;
            }
        }
        total += first * 10 + last;
    }

    std.debug.print("Part 2 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/01/example.txt");
    try part1("2023/01/input.txt");
    try part2("2023/01/example2.txt");
    try part2("2023/01/input.txt");
}
