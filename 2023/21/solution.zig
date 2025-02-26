const std = @import("std");

const Coord = struct {
    x: isize,
    y: isize,

    pub fn init(x: anytype, y: anytype) Coord {
        return Coord{ .x = @intCast(x), .y = @intCast(y) };
    }

    pub fn add(a: Coord, b: Coord) Coord {
        return Coord{ .x = a.x + b.x, .y = a.y + b.y };
    }

    pub fn scale(a: Coord, factor: anytype) Coord {
        const f: isize = @intCast(factor);
        return Coord{ .x = a.x * f, .y = a.y * f };
    }

    pub fn valid(self: Coord, width: usize, height: usize) bool {
        return self.x >= 0 and self.x < width and self.y >= 0 and self.y < height;
    }

    pub fn index(self: Coord, width: usize) usize {
        return @as(usize, @intCast(self.x)) + (@as(usize, @intCast(self.y)) * width);
    }

    pub fn wrap(self: Coord, width: usize, height: usize) Coord {
        return Coord.init(@mod(self.x, @as(isize, @intCast(width))), @mod(self.y, @as(isize, @intCast(height))));
    }

    pub fn distance(a: Coord, b: Coord) usize {
        return @abs(a.x - b.x) + @abs(a.y - b.y);
    }
};

const directions = [4]Coord{ Coord.init(0, -1), Coord.init(1, 0), Coord.init(0, 1), Coord.init(-1, 0) };

const Step = struct {
    coord: Coord,
    count: usize = 0,
};

const Queue = std.fifo.LinearFifo(Step, .Dynamic);

const Seen = std.AutoHashMap(Coord, bool);

const Counts = std.AutoHashMap(Coord, usize);

fn solve(label: []const u8, name: []const u8, maxSteps: comptime_int) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stat = try std.fs.cwd().statFile(name);
    const input = try std.fs.cwd().readFileAlloc(allocator, name, stat.size);
    var timer = try std.time.Timer.start();

    const width = std.mem.indexOfScalar(u8, input, '\n').?;
    const height = (input.len + 1) / (width + 1);
    const start = std.mem.indexOfScalar(u8, input, 'S').?;
    const startX = start % (width + 1);
    const startY = start / (width + 1);
    const plotStart = Coord.init(startX, startY);

    var plotSeen: Seen = Seen.init(allocator);
    var plotQueue: Queue = Queue.init(allocator);
    var plotCounts: Counts = Counts.init(allocator);

    const precalcDist = width * 6;
    const precalcMaxSteps = @min(maxSteps, precalcDist);
    var evenMapTotal: usize = 0;
    var oddMapTotal: usize = 0;
    var total: usize = 0;

    try plotQueue.writeItem(.{ .coord = plotStart });
    try plotSeen.put(plotStart, true);

    // Calc steps for the first few maps in each direction.
    // Further maps will only repeat.
    // We calc totals for even and odd maps to multiply later.
    while (plotQueue.readItem()) |step| {
        if (input[step.coord.wrap(width, height).index(width + 1)] == '#') continue;

        try plotCounts.put(step.coord, step.count);

        if ((maxSteps + step.count) % 2 == 0) {
            total += 1;
        }

        if (step.coord.valid(width, height)) {
            if ((maxSteps + step.count) % 2 == 0) {
                evenMapTotal += 1;
            } else {
                oddMapTotal += 1;
            }
        }

        if (step.count < precalcMaxSteps) {
            for (directions) |d| {
                const next = step.coord.add(d);
                if (plotSeen.contains(next)) continue;
                try plotSeen.put(next, true);
                try plotQueue.writeItem(.{ .coord = next, .count = step.count + 1 });
            }
        }
    }

    if (maxSteps >= precalcDist) {
        // We didn't find the total in the initial walking, now we use the patterns to calc the final total.
        total = 0;

        // Max additional maps that can be travelled.
        const maxMapsDistance = maxSteps / width;
        // Full maps inside edge.
        const fullMapsDistance = maxMapsDistance - 2;
        const evens = std.math.pow(usize, ((fullMapsDistance / 2) * 2) + 1, 2);
        const odds = std.math.pow(usize, ((fullMapsDistance + 1) / 2) * 2, 2);
        total += evenMapTotal * evens;
        total += oddMapTotal * odds;

        // Work out edges for each side.
        for (directions, 0..) |d, i| {
            const prevD = directions[if (i == 0) directions.len - 1 else i - 1];
            const Template = struct {
                coord: Coord,
                distance: usize,
                count: usize,
            };
            const templates: [6]Template = .{
                // Corners
                .{ .coord = d.scale(3), .count = 1, .distance = maxMapsDistance + 1 },
                .{ .coord = d.scale(3), .count = 1, .distance = maxMapsDistance },
                .{ .coord = d.scale(3), .count = 1, .distance = maxMapsDistance - 1 },
                // Edges
                .{ .coord = d.add(prevD), .count = maxMapsDistance, .distance = maxMapsDistance + 1 },
                .{ .coord = d.add(prevD), .count = maxMapsDistance - 1, .distance = maxMapsDistance },
                .{ .coord = d.add(prevD), .count = maxMapsDistance - 2, .distance = maxMapsDistance - 1 },
            };
            for (templates) |template| {
                const distance = (template.distance - template.coord.distance(Coord.init(0, 0))) * width;
                const plot = template.coord.scale(width);
                var templateTotal: usize = 0;
                for (0..width) |x| {
                    for (0..height) |y| {
                        if (plotCounts.get(plot.add(Coord.init(x, y)))) |templateCount| {
                            const count = templateCount + distance;
                            if (count <= maxSteps and (maxSteps - count) % 2 == 0) {
                                templateTotal += 1;
                            }
                        }
                    }
                }
                total += templateTotal * template.count;
            }
        }
    }

    std.debug.print("{s} {s} {d} {d} {d}\n", .{ label, std.fs.path.basename(name), maxSteps, total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try solve("Part 1", "2023/21/example.txt", 6);
    try solve("Part 1", "2023/21/input.txt", 64);
    try solve("Part 2", "2023/21/example.txt", 10);
    try solve("Part 2", "2023/21/example.txt", 50);
    try solve("Part 2", "2023/21/example.txt", 100);
    try solve("Part 2", "2023/21/example.txt", 500);
    try solve("Part 2", "2023/21/example.txt", 1000);
    try solve("Part 2", "2023/21/example.txt", 5000);
    try solve("Part 2", "2023/21/input.txt", 26501365);
}
