const std = @import("std");

const example = @embedFile("example.txt");
const example2 = @embedFile("example2.txt");
const input = @embedFile("input.txt");

fn part1(name: []const u8, in: []const u8) !void {
    var timer = try std.time.Timer.start();
    var total: u32 = 0;
    var first: u8 = 0;
    var firstFound: bool = false;
    var last: u8 = 0;
    for (in) |char| {
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
    std.debug.print("Part 1 {s} {d} {d}\n", .{ name, total, std.fmt.fmtDuration(timer.read()) });
}

fn part2(name: []const u8, in: []const u8) !void {
    var timer = try std.time.Timer.start();

    const words = [_][]const u8{ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

    var lines = std.mem.splitSequence(u8, in, "\n");
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
    std.debug.print("Part 2 {s} {d} {d}\n", .{ name, total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("example", example);
    try part1("input", input);
    try part2("example2", example2);
    try part2("input", input);
}
