const std = @import("std");

fn part1(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var total: usize = 0;
    var winningNumbers: [10]usize = undefined;
    @memset(&winningNumbers, 0);
    var winningIndex: u8 = 0;
    var readingWinning: bool = false;
    var readingOwn: bool = false;
    var number: u8 = 0;
    var matches: u6 = 0;

    for (input) |char| {
        if (char == ':') {
            readingWinning = true;
        }
        if (char == '|') {
            readingOwn = true;
        }
        if ((readingWinning or readingOwn)) {
            if (char >= '0' and char <= '9') {
                number = number * 10 + char - '0';
            } else if (number > 0) {
                if (readingOwn) {
                    for (winningNumbers) |winningNumber| {
                        if (number == winningNumber) {
                            matches += 1;
                        }
                    }
                } else {
                    winningNumbers[winningIndex] = number;
                    winningIndex += 1;
                }
                number = 0;
            }
        }

        if (char == '\n') {
            if (matches > 0) {
                total += @as(usize, 1) << (matches - 1);
            }
            @memset(&winningNumbers, 0);
            winningIndex = 0;
            readingWinning = false;
            readingOwn = false;
            number = 0;
            matches = 0;
        }
    }
    if (matches > 0) {
        total += @as(usize, 1) << (matches - 1);
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
    var cardCopies = [_]usize{1} ** 256;
    var card: u8 = 0;
    var winningNumbers: [10]usize = undefined;
    @memset(&winningNumbers, 0);
    var winningIndex: u8 = 0;
    var readingWinning: bool = false;
    var readingOwn: bool = false;
    var number: u8 = 0;
    var matches: u6 = 0;

    for (input) |char| {
        if (char == ':') {
            readingWinning = true;
        }
        if (char == '|') {
            readingOwn = true;
        }
        if ((readingWinning or readingOwn)) {
            if (char >= '0' and char <= '9') {
                number = number * 10 + char - '0';
            } else if (number > 0) {
                if (readingOwn) {
                    for (winningNumbers) |winningNumber| {
                        if (number == winningNumber) {
                            matches += 1;
                        }
                    }
                } else {
                    winningNumbers[winningIndex] = number;
                    winningIndex += 1;
                }
                number = 0;
            }
        }

        if (char == '\n') {
            while (matches > 0) {
                cardCopies[card + matches] += cardCopies[card];
                matches -= 1;
            }
            total += cardCopies[card];
            card += 1;
            @memset(&winningNumbers, 0);
            winningIndex = 0;
            readingWinning = false;
            readingOwn = false;
            number = 0;
        }
    }
    total += cardCopies[card];

    std.debug.print("Part 2 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/04/example.txt");
    try part1("2023/04/input.txt");
    try part2("2023/04/example.txt");
    try part2("2023/04/input.txt");
}
