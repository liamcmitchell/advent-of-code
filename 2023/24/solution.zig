const std = @import("std");

const Number = f64;

const Vec3 = struct {
    x: Number,
    y: Number,
    z: Number,

    pub fn init(x: anytype, y: anytype, z: anytype) Vec3 {
        return Vec3{ .x = @floatCast(x), .y = @floatCast(y), .z = @floatCast(z) };
    }

    pub fn add(a: Vec3, b: Vec3) Vec3 {
        return Vec3{ .x = a.x + b.x, .y = a.y + b.y, .z = a.z + b.z };
    }

    pub fn subtract(a: Vec3, b: Vec3) Vec3 {
        return Vec3{ .x = a.x - b.x, .y = a.y - b.y, .z = a.z - b.z };
    }

    pub fn scale(a: Vec3, factor: anytype) Vec3 {
        const f: Number = if (@typeInfo(@TypeOf(factor)) == .Int) @floatFromInt(factor) else factor;
        return Vec3{ .x = a.x * f, .y = a.y * f, .z = a.z * f };
    }

    pub fn length(self: Vec3) Number {
        return @sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
    }

    pub fn normalize(self: Vec3) Vec3 {
        const len = self.length();
        if (len == 0) return self;
        return Vec3{ .x = self.x / len, .y = self.y / len, .z = self.z / len };
    }

    pub fn dot(a: Vec3, b: Vec3) Number {
        return a.x * b.x + a.y * b.y + a.z * b.z;
    }

    pub fn d(m: Vec3, n: Vec3, o: Vec3, p: Vec3) Number {
        return ((m.x - n.x) * (o.x - p.x)) + ((m.y - n.y) * (o.y - p.y)) + ((m.z - n.z) * (o.z - p.z));
    }

    pub fn distance(a: Vec3, b: Vec3) Number {
        return a.subtract(b).length();
    }
};

const Hailstone = struct {
    pos: Vec3,
    vel: Vec3,

    pub fn parse(line: []const u8) !Hailstone {
        var partIt = std.mem.tokenizeAny(u8, line, ", @");
        return Hailstone{
            .pos = Vec3.init(
                try std.fmt.parseFloat(Number, partIt.next().?),
                try std.fmt.parseFloat(Number, partIt.next().?),
                try std.fmt.parseFloat(Number, partIt.next().?),
            ),
            .vel = Vec3.init(
                try std.fmt.parseFloat(Number, partIt.next().?),
                try std.fmt.parseFloat(Number, partIt.next().?),
                try std.fmt.parseFloat(Number, partIt.next().?),
            ),
        };
    }
};

fn part1(name: []const u8, min: Number, max: Number) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stat = try std.fs.cwd().statFile(name);
    const input = try std.fs.cwd().readFileAlloc(allocator, name, stat.size);
    var timer = try std.time.Timer.start();

    var hailstones = std.ArrayList(Hailstone).init(allocator);
    var lineIt = std.mem.tokenizeScalar(u8, input, '\n');
    while (lineIt.next()) |line| {
        try hailstones.append(try Hailstone.parse(line));
    }

    var total: usize = 0;
    for (hailstones.items[0 .. hailstones.items.len - 1], 0..) |a, i| {
        for (hailstones.items[i + 1 ..]) |b| {
            // Intersection point of two line segments in 2 dimensions
            // https://paulbourke.net/geometry/pointlineplane/
            const denominator = (b.vel.y * a.vel.x) - (b.vel.x * a.vel.y);

            if (denominator == 0) {
                continue;
            }

            const uA = ((b.vel.x) * (a.pos.y - b.pos.y) - (b.vel.y) * (a.pos.x - b.pos.x)) / denominator;
            const uB = ((a.vel.x) * (a.pos.y - b.pos.y) - (a.vel.y) * (a.pos.x - b.pos.x)) / denominator;
            if (uA >= 0 and uB >= 0) {
                const x = a.pos.x + uA * a.vel.x;
                const y = a.pos.y + uA * a.vel.y;
                if (x >= min and x <= max and y >= min and y <= max) {
                    total += 1;
                }
            }
        }
    }

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

fn maxDistance(p1: Vec3, p2: Vec3, stones: []Hailstone) Number {
    var max: Number = 0;
    for (stones) |b| {
        // Shortest line between two lines
        // https://paulbourke.net/geometry/pointlineplane/
        const p3 = b.pos;
        const p4 = b.pos.add(b.vel);
        const d1343 = Vec3.d(p1, p3, p4, p3);
        const d4321 = Vec3.d(p4, p3, p2, p1);
        const d1321 = Vec3.d(p1, p3, p2, p1);
        const d4343 = Vec3.d(p4, p3, p4, p3);
        const d2121 = Vec3.d(p2, p1, p2, p1);
        const denominator = (d2121 * d4343) - (d4321 * d4321);
        if (denominator == 0) continue;
        const muA = (d1343 * d4321 - d1321 * d4343) / denominator;
        const muB = (d1343 + muA * d4321) / d4343;
        const pA = p1.add(p2.subtract(p1).scale(muA));
        // Because the hailstone can only go forwards in time, pB must be at least the start pos.
        const pB = if (muB < 0) b.pos else b.pos.add(b.vel.scale(muB));
        const distance = pA.distance(pB);
        max = @max(max, distance);
    }
    return max;
}

fn sortByAngleToCenter(center: Vec3, a: Hailstone, b: Hailstone) bool {
    const aVal = center.subtract(a.pos).normalize().dot(a.vel.normalize());
    const bVal = center.subtract(b.pos).normalize().dot(b.vel.normalize());
    return aVal < bVal;
}

fn part2(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stat = try std.fs.cwd().statFile(name);
    const input = try std.fs.cwd().readFileAlloc(allocator, name, stat.size);
    var timer = try std.time.Timer.start();

    var hailstones = std.ArrayList(Hailstone).init(allocator);
    var lineIt = std.mem.tokenizeScalar(u8, input, '\n');
    var center = Vec3.init(0, 0, 0);
    while (lineIt.next()) |line| {
        const hailstone = try Hailstone.parse(line);
        try hailstones.append(hailstone);
        center = center.add(hailstone.pos);
    }
    center = center.scale(1.0 / @as(Number, @floatFromInt(hailstones.items.len)));

    // Sort by angle to center, the few pointing away from center are more useful because they will
    // produce a much narrower range when we test lines running through them.
    std.mem.sort(Hailstone, hailstones.items, center, sortByAngleToCenter);

    // Move points along h1/2 paths according to which movement reduced distance.
    const h1 = hailstones.items[0];
    const h2 = hailstones.items[1];
    const testStones = hailstones.items[2..5];
    var t1: Number = 0;
    var t2: Number = 0;
    for (0..1000000) |_| {
        const p1 = h1.pos.add(h1.vel.scale(t1));
        const p2 = h2.pos.add(h2.vel.scale(t2));
        const distance = maxDistance(p1, p2, testStones);

        const test1 = h1.pos.add(h1.vel.scale(t1 + 1));
        const test2 = h2.pos.add(h2.vel.scale(t2 + 1));

        const dist1 = maxDistance(test1, p2, testStones);
        const diff1 = distance - dist1;
        const dist2 = maxDistance(p1, test2, testStones);
        const diff2 = distance - dist2;
        const distBoth = maxDistance(test1, test2, testStones);
        const diffBoth = distance - distBoth;

        if (diffBoth > 0 and diffBoth > diff1 and diffBoth > diff2) {
            const factor = (std.math.ceil((distance / diffBoth) * 0.001));
            t1 += factor;
            t2 += factor;
        } else if (diff1 > 0 and diff1 > diff2) {
            const factor = (std.math.ceil((distance / diff1) * 0.001));
            t1 += factor;
        } else if (diff2 > 0) {
            const factor = (std.math.ceil((distance / diff2) * 0.001));
            t2 += factor;
        } else {
            // Found line, might not be exactly 0 but can't go further.
            break;
        }
    }

    const p1 = h1.pos.add(h1.vel.scale(t1));
    const p2 = h2.pos.add(h2.vel.scale(t2));
    const vel = p1.subtract(p2).scale(1 / (t1 - t2));
    const pos = p1.subtract(vel.scale(t1));

    const total = pos.x + pos.y + pos.z;

    std.debug.print("Part 2 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/24/example.txt", 7, 27);
    try part1("2023/24/input.txt", 200000000000000, 400000000000000);
    try part2("2023/24/example.txt");
    try part2("2023/24/input.txt");
}
