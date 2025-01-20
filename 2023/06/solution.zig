const std = @import("std");

// Distance is a simple exponential so we only need to find the first winning distance
// and can then calculate the distance to it's mirror on the other side.
fn waysToBeat(time: usize, distanceToBeat: usize) usize {
    var minMin: usize = 0;
    var minMax: usize = time / 2;
    while (minMin < minMax) {
        const mid = minMin + (minMax - minMin) / 2;
        const distance = (mid * (time - mid));
        if (distance <= distanceToBeat) {
            minMin = mid + 1;
        } else {
            minMax = mid;
        }
    }

    return (time - minMin) - minMin + 1;
}

fn part1(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var total: usize = 1;
    var number: usize = 0;
    var times = std.ArrayList(usize).init(allocator);
    var index: u8 = 0;
    var readingTimes: bool = true;

    for (input) |char| {
        if (char >= '0' and char <= '9') {
            number = number * 10 + char - '0';
        } else if (number > 0) {
            if (readingTimes) {
                try times.append(number);
            } else {
                total = total * waysToBeat(times.items[index], number);
                index += 1;
            }
            number = 0;
        }

        if (char == '\n') {
            readingTimes = false;
        }
    }
    total = total * waysToBeat(times.items[index], number);

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

fn part2(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var total: usize = 1;
    var time: usize = 0;
    var distanceToBeat: usize = 0;
    var readingTimes: bool = true;

    for (input) |char| {
        if (char >= '0' and char <= '9') {
            if (readingTimes) {
                time = time * 10 + char - '0';
            } else {
                distanceToBeat = distanceToBeat * 10 + char - '0';
            }
        }

        if (char == '\n') {
            readingTimes = false;
        }
    }
    total = total * waysToBeat(time, distanceToBeat);

    std.debug.print("Part 2 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/06/example.txt");
    try part1("2023/06/input.txt");
    try part2("2023/06/example.txt");
    try part2("2023/06/input.txt");
}
