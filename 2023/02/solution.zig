const std = @import("std");

fn part1(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var total: u32 = 0;
    var game: u8 = 1;
    var maxRed: u8 = 0;
    var maxGreen: u8 = 0;
    var maxBlue: u8 = 0;
    var number: u8 = 0;
    var foundSeparator: bool = false;
    for (input) |char| {
        if (char == ':' or char == ';' or char == ',') {
            foundSeparator = true;
        }
        if (foundSeparator) {
            if (char >= '0' and char <= '9') {
                number = number * 10 + char - '0';
            }
            if (char == 'r') {
                maxRed = @max(maxRed, number);
                number = 0;
                foundSeparator = false;
            }
            if (char == 'g') {
                maxGreen = @max(maxGreen, number);
                number = 0;
                foundSeparator = false;
            }
            if (char == 'b') {
                maxBlue = @max(maxBlue, number);
                number = 0;
                foundSeparator = false;
            }
        }

        if (char == '\n') {
            if (maxRed <= 12 and
                maxGreen <= 13 and
                maxBlue <= 14)
            {
                total += game;
            }
            maxRed = 0;
            maxGreen = 0;
            maxBlue = 0;
            number = 0;
            foundSeparator = false;
            game += 1;
        }
    }
    if (maxRed <= 12 and
        maxGreen <= 13 and
        maxBlue <= 14)
    {
        total += game;
    }

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

fn part2(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var total: u32 = 0;
    var game: u8 = 1;
    var maxRed: u32 = 0;
    var maxGreen: u32 = 0;
    var maxBlue: u32 = 0;
    var number: u8 = 0;
    var foundSeparator: bool = false;
    for (input) |char| {
        if (char == ':' or char == ';' or char == ',') {
            foundSeparator = true;
        }
        if (foundSeparator) {
            if (char >= '0' and char <= '9') {
                number = number * 10 + char - '0';
            }
            if (char == 'r') {
                maxRed = @max(maxRed, number);
                number = 0;
                foundSeparator = false;
            }
            if (char == 'g') {
                maxGreen = @max(maxGreen, number);
                number = 0;
                foundSeparator = false;
            }
            if (char == 'b') {
                maxBlue = @max(maxBlue, number);
                number = 0;
                foundSeparator = false;
            }
        }

        if (char == '\n') {
            total += maxRed * maxGreen * maxBlue;
            maxRed = 0;
            maxGreen = 0;
            maxBlue = 0;
            number = 0;
            foundSeparator = false;
            game += 1;
        }
    }
    total += maxRed * maxGreen * maxBlue;

    std.debug.print("Part 2 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/02/example.txt");
    try part1("2023/02/input.txt");
    try part2("2023/02/example.txt");
    try part2("2023/02/input.txt");
}
