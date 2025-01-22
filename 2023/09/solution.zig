const std = @import("std");

fn part1(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var total: i32 = 0;

    var lineIt = std.mem.tokenizeScalar(u8, input, '\n');
    while (lineIt.next()) |line| {
        var lastNums = std.ArrayList(i32).init(allocator);
        var currentNums = std.ArrayList(i32).init(allocator);

        var numberIt = std.mem.tokenizeScalar(u8, line, ' ');
        while (numberIt.next()) |number| {

            // swap last and current
            const tmp = lastNums;
            lastNums = currentNums;
            currentNums = tmp;

            var current = try std.fmt.parseInt(i32, number, 10);
            for (0..lastNums.items.len + 1) |i| {
                if (currentNums.items.len <= i) {
                    try currentNums.append(current);
                } else {
                    currentNums.items[i] = current;
                }
                var last: i32 = 0;
                if (lastNums.items.len > i) {
                    last = lastNums.items[i];
                }

                current = current - last;
            }
        }

        var nextNum: i32 = 0;
        for (currentNums.items) |num| {
            nextNum += num;
        }
        total += nextNum;
    }

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

fn part2(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var total: i32 = 0;
    var prevNums: [22]i32 = undefined;
    var currNums: [22]i32 = undefined;

    var lineIt = std.mem.tokenizeScalar(u8, input, '\n');
    while (lineIt.next()) |line| {
        @memset(&prevNums, 0);
        @memset(&currNums, 0);
        var len: u8 = 0;
        var numberIt = std.mem.tokenizeScalar(u8, line, ' ');
        while (numberIt.next()) |number| {
            // swap last and current
            const tmp = prevNums;
            prevNums = currNums;
            currNums = tmp;

            var current = try std.fmt.parseInt(i32, number, 10);
            for (0..len + 1) |i| {
                currNums[i] = current;
                current = current - prevNums[i];
            }
            len += 1;
        }

        // Go backwards
        for (0..len) |i| {
            for (0..len - i) |j| {
                prevNums[j] = currNums[j] - currNums[j + 1];
            }

            // swap last and current
            const tmp = prevNums;
            prevNums = currNums;
            currNums = tmp;
        }

        total += currNums[0];
    }

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/09/example.txt");
    try part1("2023/09/input.txt");
    try part2("2023/09/example.txt");
    try part2("2023/09/input.txt");
}
