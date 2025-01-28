const std = @import("std");

const Directions = struct {
    up: isize,
    right: isize = 1,
    down: isize,
    left: isize = -1,
    index: u8 = 0,

    pub fn init(width: isize) Directions {
        return Directions{
            .up = -width,
            .down = width,
        };
    }

    pub fn get(self: Directions, index: usize) isize {
        return switch (index % 4) {
            0 => self.up,
            1 => self.right,
            2 => self.down,
            else => self.left,
        };
    }
};

fn followLoop(allocator: std.mem.Allocator, input: []const u8, directions: Directions) !std.ArrayList(usize) {
    const start = @as(isize, @intCast(std.mem.indexOfScalar(u8, input, 'S').?));
    var prev = start;
    var current: isize = 0;
    var loop = try std.ArrayList(usize).initCapacity(allocator, input.len);
    try loop.append(@intCast(start));

    directions: for (0..4) |index| {
        current = prev + directions.get(index);
        if (current < 0 or current >= input.len) {
            continue :directions;
        }
        while (current != start) {
            var a: isize = 0;
            var b: isize = 0;
            switch (input[@intCast(current)]) {
                '|' => {
                    a = directions.up;
                    b = directions.down;
                },
                '-' => {
                    a = directions.left;
                    b = directions.right;
                },
                'L' => {
                    a = directions.up;
                    b = directions.right;
                },
                'J' => {
                    a = directions.up;
                    b = directions.left;
                },
                '7' => {
                    a = directions.left;
                    b = directions.down;
                },
                'F' => {
                    a = directions.down;
                    b = directions.right;
                },
                else => {},
            }
            if (prev == current + a) {
                prev = current;
                current = current + b;
            } else if (prev == current + b) {
                prev = current;
                current = current + a;
            } else {
                // No link to prev, we started with the wrong direction.
                continue :directions;
            }
            try loop.append(@intCast(prev));
        }
        break;
    }
    return loop;
}

fn part1(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    const width = @as(isize, @intCast(std.mem.indexOfScalar(u8, input, '\n').?)) + 1;
    const directions = Directions.init(width);
    const loop = try followLoop(allocator, input, directions);
    const total = loop.items.len / 2;

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

fn part2(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    const width = @as(isize, @intCast(std.mem.indexOfScalar(u8, input, '\n').?)) + 1;
    const directions = Directions.init(width);
    const loop = try followLoop(allocator, input, directions);
    var inLoop = try allocator.alloc(bool, input.len);
    for (loop.items) |pipe| {
        inLoop[pipe] = true;
    }

    // Loop a second time to collect nodes to the left and right of loop.
    // One of the sides will be inside.
    var leftOfLoop = try allocator.alloc(bool, input.len);
    var leftOfLoopCount: usize = 0;
    var leftIsOutside = false;
    var rightOfLoop = try allocator.alloc(bool, input.len);
    var rightOfLoopCount: usize = 0;
    var rightIsOutside = false;
    var prev: isize = 0;
    var current: isize = @intCast(loop.items[loop.items.len - 2]);
    var next: isize = @intCast(loop.items[loop.items.len - 1]);
    for (loop.items) |_next| {
        prev = current;
        current = next;
        next = @intCast(_next);
        const prevDirection = prev - current;
        const nextDirection = next - current;
        var foundPrev = false;
        var foundNext = false;
        var lookingLeft = false;
        // Iterate over directions (clockwise), from prev to next.
        forClockwise: for (0..8) |i| {
            const direction = directions.get(i);
            if (direction == prevDirection) {
                if (foundPrev) break :forClockwise;
                foundPrev = true;
                lookingLeft = true;
            } else if (direction == nextDirection) {
                if (foundNext) break :forClockwise;
                foundNext = true;
                lookingLeft = false;
            } else if (foundPrev and lookingLeft and !leftIsOutside) {
                // Go left until hitting edge, loop or already counted nodes.
                var leftOfCurrent = current + direction;
                whileLookingLeft: while (true) {
                    if (leftOfCurrent < 0 or leftOfCurrent >= input.len or input[@intCast(leftOfCurrent)] == '\n') {
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
                    leftOfCurrent = leftOfCurrent + direction;
                }
            } else if (foundNext and !lookingLeft and !rightIsOutside) {
                // Go right until hitting edge, loop or already counted nodes.
                var rightOfCurrent = current + direction;
                whileLookingRight: while (true) {
                    if (rightOfCurrent < 0 or rightOfCurrent >= input.len or input[@intCast(rightOfCurrent)] == '\n') {
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
                    rightOfCurrent = rightOfCurrent + direction;
                }
            }
        }
    }

    const total = if (leftIsOutside) rightOfLoopCount else leftOfLoopCount;

    std.debug.print("Part 2 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/10/example.txt");
    try part1("2023/10/input.txt");
    try part2("2023/10/example2.txt");
    try part2("2023/10/example3.txt");
    try part2("2023/10/input.txt");
}
