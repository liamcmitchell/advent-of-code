const std = @import("std");

const Dir = enum {
    up,
    right,
    down,
    left,
};

const dirCount: comptime_int = @typeInfo(Dir).Enum.fields.len;

const Cost = u16;

const Path = struct {
    x: isize,
    y: isize,
    dir: Dir,
    cost: Cost,
    steps: u4 = 0,

    pub fn move(self: *Path) void {
        switch (self.dir) {
            .up => self.y -= 1,
            .right => self.x += 1,
            .down => self.y += 1,
            .left => self.x -= 1,
        }
        self.steps += 1;
    }

    pub fn turn(self: Path, dir: Dir) Path {
        return Path{
            .x = self.x,
            .y = self.y,
            .cost = self.cost,
            .dir = switch (dir) {
                .left => switch (self.dir) {
                    .up => .left,
                    .right => .up,
                    .down => .right,
                    .left => .down,
                },
                .right => switch (self.dir) {
                    .up => .right,
                    .right => .down,
                    .down => .left,
                    .left => .up,
                },
                else => @panic("can only turn left or right"),
            },
        };
    }

    pub fn valid(self: Path, width: usize, height: usize) bool {
        return self.x >= 0 and self.x < width and self.y >= 0 and self.y < height;
    }

    pub fn index(self: Path, width: usize) usize {
        return @as(usize, @intCast(self.x)) + (@as(usize, @intCast(self.y)) * width);
    }
};

fn comparePaths(_: void, a: Path, b: Path) std.math.Order {
    if (a.cost != b.cost) {
        return std.math.order(a.cost, b.cost);
    }
    return std.math.order(-a.x - a.y, -b.x - b.y);
}

const Queue = std.PriorityQueue(Path, void, comparePaths);

fn solve(part: comptime_int, name: []const u8, minSteps: comptime_int, maxSteps: comptime_int) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    const width = std.mem.indexOfScalar(u8, input, '\n').?;
    const height = (input.len + 1) / (width + 1);

    const cost = try allocator.alloc(u4, width * height);
    for (0..width) |x| {
        for (0..height) |y| {
            cost[x + (y * width)] = @intCast(input[x + (y * (width + 1))] - '0');
        }
    }

    // Store cost for each visited block/direction/steps.
    const visited = try allocator.alloc([dirCount][maxSteps]Cost, width * height);
    @memset(visited, .{.{std.math.maxInt(Cost)} ** maxSteps} ** dirCount);

    var queue = Queue.init(allocator, {});
    try queue.add(.{ .x = 0, .y = 0, .cost = 0, .dir = .right });
    try queue.add(.{ .x = 0, .y = 0, .cost = 0, .dir = .down });

    const goalX = width - 1;
    const goalY = height - 1;

    var total: Cost = 0;
    paths: while (queue.removeOrNull()) |p| {
        var options: [3]Path = [3]Path{ p, p.turn(.left), p.turn(.right) };
        for (&options) |*path| {
            if (path.steps == maxSteps or (p.dir != path.dir and p.steps < minSteps)) continue;
            path.move();
            if (!path.valid(width, height)) continue;
            const index = path.index(width);
            path.cost += cost[index];
            if (path.x == goalX and path.y == goalY and path.steps >= minSteps) {
                total = path.cost;
                break :paths;
            }
            const visitedCost = &visited[index][@intFromEnum(path.dir)][path.steps - 1];
            if (visitedCost.* <= path.cost) {
                // Skip if another path has visited in this direction with same or lower cost.
                continue;
            }
            // Set new minimum cost for this block/direction/steps.
            visitedCost.* = path.cost;
            try queue.add(path.*);
        }

        if (queue.items.len > 100000) {
            std.debug.print("didn't find goal\n", .{});
            return;
        }
    }

    std.debug.print("Part {d} {s} {d} {d}\n", .{ part, std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try solve(1, "2023/17/example.txt", 0, 3);
    try solve(1, "2023/17/input.txt", 0, 3);
    try solve(2, "2023/17/example.txt", 4, 10);
    try solve(2, "2023/17/input.txt", 4, 10);
}
