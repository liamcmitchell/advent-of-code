const std = @import("std");

const Coord = struct {
    x: u4,
    y: u4,
};

const Brick = struct {
    x1: u4,
    y1: u4,
    z1: u9,
    x2: u4,
    y2: u4,
    z2: u9,
    supporting: BrickSet,
    supportedBy: BrickSet,

    pub fn lessThan(_: void, lhs: *Brick, rhs: *Brick) bool {
        return lhs.z1 < rhs.z1;
    }
};

const BrickSet = std.AutoHashMap(*Brick, void);

const Bricks = std.ArrayList(*Brick);

fn parse(allocator: std.mem.Allocator, input: []const u8) !Bricks {
    var bricks = Bricks.init(allocator);

    var lineIt = std.mem.tokenizeScalar(u8, input, '\n');
    while (lineIt.next()) |line| {
        var brickIt = std.mem.tokenizeAny(u8, line, ",~");
        const brick = try allocator.create(Brick);
        brick.* = Brick{
            .x1 = try std.fmt.parseInt(u4, brickIt.next().?, 10),
            .y1 = try std.fmt.parseInt(u4, brickIt.next().?, 10),
            .z1 = @intCast(try std.fmt.parseInt(u9, brickIt.next().?, 10)),
            .x2 = try std.fmt.parseInt(u4, brickIt.next().?, 10),
            .y2 = try std.fmt.parseInt(u4, brickIt.next().?, 10),
            .z2 = @intCast(try std.fmt.parseInt(u9, brickIt.next().?, 10)),
            .supporting = BrickSet.init(allocator),
            .supportedBy = BrickSet.init(allocator),
        };
        try bricks.append(brick);
    }
    std.mem.sort(*Brick, bricks.items, {}, Brick.lessThan);

    var columns = std.AutoHashMap(Coord, Bricks).init(allocator);
    for (0..10) |x| {
        for (0..10) |y| {
            try columns.put(Coord{ .x = @intCast(x), .y = @intCast(y) }, Bricks.init(allocator));
        }
    }

    for (bricks.items) |brick| {
        // Iterate over columns to get max Z.
        var maxZ: u9 = 0;
        for (brick.x1..brick.x2 + 1) |x| {
            for (brick.y1..brick.y2 + 1) |y| {
                const column = columns.get(Coord{ .x = @intCast(x), .y = @intCast(y) }).?;
                if (column.getLastOrNull()) |colBrick| {
                    maxZ = @max(maxZ, colBrick.z2);
                }
            }
        }

        // Update z.
        const height = brick.z2 - brick.z1;
        brick.z1 = maxZ + 1;
        brick.z2 = maxZ + 1 + height;

        // Iterate over columns again to connect bricks and add to columns.
        for (brick.x1..brick.x2 + 1) |x| {
            for (brick.y1..brick.y2 + 1) |y| {
                const column = columns.getPtr(Coord{ .x = @intCast(x), .y = @intCast(y) }).?;
                if (column.getLastOrNull()) |colBrick| {
                    if (colBrick.z2 == maxZ) {
                        try colBrick.supporting.put(brick, {});
                        try brick.supportedBy.put(colBrick, {});
                    }
                }
                try column.append(brick);
            }
        }
    }

    return bricks;
}

fn part1(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stat = try std.fs.cwd().statFile(name);
    const input = try std.fs.cwd().readFileAlloc(allocator, name, stat.size);
    var timer = try std.time.Timer.start();

    const bricks = try parse(allocator, input);

    // Count bricks that can be disintegrated.
    var total: usize = 0;
    for (bricks.items) |brick| {
        var canDisintegrate = true;
        var supportingIt = brick.supporting.keyIterator();
        while (supportingIt.next()) |supportedPtr| {
            const supported = supportedPtr.*;
            if (supported.supportedBy.count() == 1) {
                canDisintegrate = false;
            }
        }
        if (canDisintegrate) total += 1;
    }

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

fn part2(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stat = try std.fs.cwd().statFile(name);
    const input = try std.fs.cwd().readFileAlloc(allocator, name, stat.size);
    var timer = try std.time.Timer.start();

    const bricks = try parse(allocator, input);

    // Count bricks that will fall after disintegrating single brick.
    var total: usize = 0;
    var fallen = BrickSet.init(allocator);
    const Queue = std.fifo.LinearFifo(*Brick, .Dynamic);
    var queue: Queue = Queue.init(allocator);
    for (bricks.items) |brick| {
        fallen.clearRetainingCapacity();
        try fallen.put(brick, {});
        try queue.writeItem(brick);
        while (queue.readItem()) |falling| {
            var supportingIt = falling.supporting.keyIterator();
            while (supportingIt.next()) |supportedPtr| {
                const supported = supportedPtr.*;
                var canFall = true;
                var supporterIt = supported.supportedBy.keyIterator();
                while (supporterIt.next()) |supporterPtr| {
                    const supporter = supporterPtr.*;
                    if (!fallen.contains(supporter)) {
                        canFall = false;
                    }
                }
                if (canFall) {
                    try fallen.put(supported, {});
                    try queue.writeItem(supported);
                }
            }
        }
        total += fallen.count() - 1;
    }

    std.debug.print("Part 2 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/22/example.txt");
    try part1("2023/22/input.txt");
    try part2("2023/22/example.txt");
    try part2("2023/22/input.txt");
}
