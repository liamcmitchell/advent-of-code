const std = @import("std");

const Item = enum {
    empty,
    round,
    cube,
};

const Coord = struct {
    x: isize,
    y: isize,

    pub fn init(x: anytype, y: anytype) Coord {
        return Coord{ .x = @intCast(x), .y = @intCast(y) };
    }

    pub fn add(a: Coord, b: Coord) Coord {
        return Coord{ .x = a.x + b.x, .y = a.y + b.y };
    }

    pub const north = Coord{ .x = 0, .y = -1 };
    pub const east = Coord{ .x = 1, .y = 0 };
    pub const south = Coord{ .x = 0, .y = 1 };
    pub const west = Coord{ .x = -1, .y = 0 };
};

const Grid = struct {
    width: usize,
    height: usize,
    items: []Item,

    pub fn init(allocator: std.mem.Allocator, input: []const u8) !Grid {
        const width = std.mem.indexOfScalar(u8, input, '\n').?;
        const height = (input.len + 1) / (width + 1);
        const items = try allocator.alloc(Item, width * height);

        const grid = Grid{
            .items = items,
            .width = width,
            .height = height,
        };

        for (0..width) |x| {
            for (0..height) |y| {
                const char = input[(y * (width + 1)) + x];
                const item: Item = switch (char) {
                    'O' => .round,
                    '#' => .cube,
                    else => .empty,
                };
                grid.set(x, y, item);
            }
        }

        return grid;
    }

    pub fn get(self: Grid, x: anytype, y: anytype) Item {
        return self.items[@as(usize, @intCast(y)) * self.width + @as(usize, @intCast(x))];
    }

    pub fn set(self: Grid, x: anytype, y: anytype, item: Item) void {
        self.items[@as(usize, @intCast(y)) * self.width + @as(usize, @intCast(x))] = item;
    }

    pub fn load(self: Grid) usize {
        var total: usize = 0;
        for (0..self.width) |x| {
            for (0..self.height) |y| {
                if (self.get(x, y) == .round) {
                    total += self.height - y;
                }
            }
        }
        return total;
    }

    fn tilt(self: Grid, direction: Coord) void {
        // Both example and input are square so this could be simplified.
        const outerCount = if (direction.x == 0) self.width else self.height;
        const innerCount = if (direction.x == 0) self.height else self.width;

        for (0..outerCount) |outer| {
            for (0..innerCount) |inner| {
                const current = Coord.init(
                    if (direction.x == 0) outer else if (direction.x < 0) inner else innerCount - 1 - inner,
                    if (direction.y == 0) outer else if (direction.y < 0) inner else innerCount - 1 - inner,
                );

                if (self.get(current.x, current.y) == .round) {
                    var canMove = false;
                    var next = current;
                    for (0..inner) |_| {
                        const maybeNext = next.add(direction);
                        if (self.get(maybeNext.x, maybeNext.y) == .empty) {
                            canMove = true;
                            next = maybeNext;
                        }
                    }
                    if (canMove) {
                        self.set(current.x, current.y, .empty);
                        self.set(next.x, next.y, .round);
                    }
                }
            }
        }
    }
};

fn part1(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var grid = try Grid.init(allocator, input);
    grid.tilt(Coord.north);
    const total = grid.load();

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

fn part2(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var grid = try Grid.init(allocator, input);

    var cycles = std.ArrayList(usize).init(allocator);

    for (0..1000) |cycle| {
        grid.tilt(Coord.north);
        grid.tilt(Coord.west);
        grid.tilt(Coord.south);
        grid.tilt(Coord.east);
        try cycles.append(grid.load());

        // Look for a pattern at least 3 long, repeated 3 times.
        for (3..100) |n| {
            if (3 * n > cycle) break;
            const a = cycle + 1 - (n * 3);
            const b = cycle + 1 - (n * 2);
            const c = cycle + 1 - (n * 1);
            const d = cycle + 1;
            if (std.mem.eql(usize, cycles.items[a..b], cycles.items[b..c]) and std.mem.eql(usize, cycles.items[a..b], cycles.items[c..d])) {
                const total = cycles.items[a + ((1000000000 - 1 - a) % n)];
                std.debug.print("Part 2 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
                return;
            }
        }
    }
    @panic("Part 2 didn't complete");
}

pub fn main() !void {
    try part1("2023/14/example.txt");
    try part1("2023/14/input.txt");
    try part2("2023/14/example.txt");
    try part2("2023/14/input.txt");
}
