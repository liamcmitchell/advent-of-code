const std = @import("std");

const Dir = enum(u4) {
    up = 1,
    right = 2,
    down = 4,
    left = 8,
};

const Beam = struct {
    x: isize,
    y: isize,
    dir: Dir,

    pub fn move(self: *Beam) void {
        switch (self.dir) {
            .up => self.y -= 1,
            .right => self.x += 1,
            .down => self.y += 1,
            .left => self.x -= 1,
        }
    }

    pub fn valid(self: Beam, width: usize, height: usize) bool {
        return self.x >= 0 and self.x < width and self.y >= 0 and self.y < height;
    }

    pub fn index(self: Beam, width: usize) usize {
        return @as(usize, @intCast(self.x)) + (@as(usize, @intCast(self.y)) * width);
    }
};

const Contraption = struct {
    input: []const u8,
    width: usize,
    height: usize,
    grid: []u4,
    beams: std.ArrayList(Beam),

    pub fn init(allocator: std.mem.Allocator, input: []const u8) !Contraption {
        const width = std.mem.indexOfScalar(u8, input, '\n').?;
        const height = (input.len + 1) / (width + 1);
        const grid = try allocator.alloc(u4, width * height);
        const beams = std.ArrayList(Beam).init(allocator);

        return Contraption{
            .input = input,
            .width = width,
            .height = height,
            .grid = grid,
            .beams = beams,
        };
    }

    pub fn calcEnergized(self: *Contraption, start: Beam) !usize {
        @memset(self.grid, 0);
        self.beams.clearRetainingCapacity();
        try self.beams.append(start);
        var total: usize = 0;
        var i: usize = 0;
        while (i < self.beams.items.len) : (i += 1) {
            const beam = &self.beams.items[i];

            while (beam.valid(self.width, self.height)) : (beam.move()) {
                const gridSquare = &self.grid[beam.index(self.width)];

                if (gridSquare.* == 0) {
                    total += 1;
                }

                if (gridSquare.* & @intFromEnum(beam.dir) > 0) {
                    // Beam already passed in this direction.
                    break;
                }

                // Mark beam passing.
                gridSquare.* |= @intFromEnum(beam.dir);

                const char = self.input[beam.index(self.width + 1)];

                switch (char) {
                    '/' => {
                        beam.dir = switch (beam.dir) {
                            .up => .right,
                            .right => .up,
                            .down => .left,
                            .left => .down,
                        };
                    },
                    '\\' => {
                        beam.dir = switch (beam.dir) {
                            .up => .left,
                            .right => .down,
                            .down => .right,
                            .left => .up,
                        };
                    },
                    '|' => {
                        switch (beam.dir) {
                            .left, .right => {
                                beam.dir = .up;
                                try self.beams.append(.{ .x = beam.x, .y = beam.y, .dir = .down });
                            },
                            else => {},
                        }
                    },
                    '-' => {
                        switch (beam.dir) {
                            .up, .down => {
                                beam.dir = .left;
                                try self.beams.append(.{ .x = beam.x, .y = beam.y, .dir = .right });
                            },
                            else => {},
                        }
                    },
                    else => {},
                }
            }
        }
        return total;
    }
};

fn part1(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var contraption = try Contraption.init(allocator, input);
    const total = try contraption.calcEnergized(.{ .x = 0, .y = 0, .dir = .right });

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

fn part2(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var contraption = try Contraption.init(allocator, input);
    var total: usize = 0;
    for (0..contraption.width) |x| {
        total = @max(total, try contraption.calcEnergized(.{ .x = @intCast(x), .y = 0, .dir = .down }));
        total = @max(total, try contraption.calcEnergized(.{ .x = @intCast(x), .y = @intCast(contraption.height - 1), .dir = .up }));
    }
    for (0..contraption.height) |y| {
        total = @max(total, try contraption.calcEnergized(.{ .x = 0, .y = @intCast(y), .dir = .right }));
        total = @max(total, try contraption.calcEnergized(.{ .x = @intCast(contraption.width - 1), .y = @intCast(y), .dir = .left }));
    }

    std.debug.print("Part 2 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/16/example.txt");
    try part1("2023/16/input.txt");
    try part2("2023/16/example.txt");
    try part2("2023/16/input.txt");
}
