const std = @import("std");

fn part1(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    const width = @as(isize, @intCast(std.mem.indexOfScalar(u8, input, '\n').?)) + 1;
    const start = @as(isize, @intCast(std.mem.indexOfScalar(u8, input, 'S').?));
    const up: isize = -width;
    const right: isize = 1;
    const down: isize = width;
    const left: isize = -1;
    var prev = start;
    var current: isize = 0;
    var loopLen: usize = 1;
    directions: for ([_]isize{ up, right, down, left }) |direction| {
        current = prev + direction;
        if (current < 0 or current >= input.len) {
            continue;
        }
        while (current != start) {
            var a: isize = 0;
            var b: isize = 0;
            switch (input[@intCast(current)]) {
                '|' => {
                    a = up;
                    b = down;
                },
                '-' => {
                    a = left;
                    b = right;
                },
                'L' => {
                    a = up;
                    b = right;
                },
                'J' => {
                    a = up;
                    b = left;
                },
                '7' => {
                    a = left;
                    b = down;
                },
                'F' => {
                    a = down;
                    b = right;
                },
                else => {
                    continue :directions;
                },
            }
            if (prev == current + a) {
                prev = current;
                current = current + b;
            } else if (prev == current + b) {
                prev = current;
                current = current + a;
            } else {
                @panic("no link to prev");
            }
            loopLen += 1;
        }
        break;
    }
    const total = loopLen / 2;

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

fn part2(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    const width = @as(isize, @intCast(std.mem.indexOfScalar(u8, input, '\n').?)) + 1;
    const start = @as(isize, @intCast(std.mem.indexOfScalar(u8, input, 'S').?));
    var inLoop = try allocator.alloc(bool, input.len);
    inLoop[@intCast(start)] = true;
    const up: isize = -width;
    const right: isize = 1;
    const down: isize = width;
    const left: isize = -1;
    const directions = [_]isize{ up, right, down, left };
    var prev = start;
    var current: isize = 0;
    var loopLen: usize = 1;
    directions: for (directions) |startDirection| {
        current = prev + startDirection;
        if (current < 0 or current >= input.len) {
            continue;
        }
        while (current != start) {
            var a: isize = 0;
            var b: isize = 0;
            switch (input[@intCast(current)]) {
                '|' => {
                    a = up;
                    b = down;
                },
                '-' => {
                    a = left;
                    b = right;
                },
                'L' => {
                    a = up;
                    b = right;
                },
                'J' => {
                    a = up;
                    b = left;
                },
                '7' => {
                    a = left;
                    b = down;
                },
                'F' => {
                    a = down;
                    b = right;
                },
                else => {
                    continue :directions;
                },
            }
            if (prev == current + a) {
                a = b;
            } else if (prev != current + b) {
                continue :directions;
            }
            prev = current;
            current = current + a;
            inLoop[@intCast(prev)] = true;
            loopLen += 1;
        }
        break;
    }

    // Loop a second time to collect nodes to the left and right of loop.
    var leftOfLoop = try allocator.alloc(bool, input.len);
    var leftOfLoopCount: usize = 0;
    var leftIsOutside = false;
    var rightOfLoop = try allocator.alloc(bool, input.len);
    var rightOfLoopCount: usize = 0;
    var rightIsOutside = false;
    prev = start;
    current = 0;
    directions: for (directions) |startDirection| {
        current = prev + startDirection;
        if (current < 0 or current >= input.len) {
            continue;
        }
        while (current != start) {
            var a: isize = 0;
            var b: isize = 0;
            switch (input[@intCast(current)]) {
                '|' => {
                    a = up;
                    b = down;
                },
                '-' => {
                    a = left;
                    b = right;
                },
                'L' => {
                    a = up;
                    b = right;
                },
                'J' => {
                    a = up;
                    b = left;
                },
                '7' => {
                    a = left;
                    b = down;
                },
                'F' => {
                    a = down;
                    b = right;
                },
                else => {},
            }
            var nextDirection: isize = 0;
            var prevDirection: isize = 0;
            if (prev == current + a) {
                nextDirection = b;
                prevDirection = a;
            } else if (prev == current + b) {
                nextDirection = a;
                prevDirection = b;
            } else {
                continue :directions;
            }
            // Iterate over directions (clockwise), from prev to next.
            var foundPrev = false;
            var foundNext = false;
            var lookingLeft = false;
            forClockwise: for (0..12) |i| {
                const d = directions[i % directions.len];
                if (d == prevDirection) {
                    if (foundPrev) break :forClockwise;
                    foundPrev = true;
                    lookingLeft = true;
                } else if (d == nextDirection) {
                    if (foundNext) break :forClockwise;
                    foundNext = true;
                    lookingLeft = false;
                } else if (foundPrev and lookingLeft) {

                    // Go left until hitting edge, loop or already counted nodes.
                    var leftOfCurrent = current + d;
                    whileLookingLeft: while (true) {
                        if (leftOfCurrent < 0 or leftOfCurrent >= input.len) {
                            leftIsOutside = true;
                            break :whileLookingLeft;
                        }
                        if (input[@intCast(leftOfCurrent)] == '\n') {
                            leftIsOutside = true;
                            break :whileLookingLeft;
                        }
                        if (inLoop[@intCast(leftOfCurrent)] == true) {
                            break :whileLookingLeft;
                        }
                        if (!leftOfLoop[@intCast(leftOfCurrent)]) {
                            leftOfLoopCount += 1;
                            leftOfLoop[@intCast(leftOfCurrent)] = true;
                        }
                        leftOfCurrent = leftOfCurrent + d;
                    }
                } else if (foundNext and !lookingLeft) {
                    // Go right until hitting edge, loop or already counted nodes.
                    var rightOfCurrent = current + d;
                    whileLookingRight: while (true) {
                        if (rightOfCurrent < 0 or rightOfCurrent >= input.len) {
                            rightIsOutside = true;
                            break :whileLookingRight;
                        }
                        if (input[@intCast(rightOfCurrent)] == '\n') {
                            rightIsOutside = true;
                            break :whileLookingRight;
                        }
                        if (inLoop[@intCast(rightOfCurrent)] == true) {
                            break :whileLookingRight;
                        }
                        if (!rightOfLoop[@intCast(rightOfCurrent)]) {
                            rightOfLoopCount += 1;
                            rightOfLoop[@intCast(rightOfCurrent)] = true;
                        }
                        rightOfCurrent = rightOfCurrent + d;
                    }
                }
            }

            prev = current;
            current = current + nextDirection;
        }
        break;
    }

    var total: usize = 0;
    if (leftIsOutside) {
        total = rightOfLoopCount;
    } else {
        total = leftOfLoopCount;
    }

    std.debug.print("Part 2 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/10/example.txt");
    try part1("2023/10/input.txt");
    try part2("2023/10/example2.txt");
    try part2("2023/10/example3.txt");
    try part2("2023/10/input.txt");
}
