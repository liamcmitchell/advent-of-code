const std = @import("std");

const NodeName = []const u8;

const Fork = struct {
    left: NodeName,
    right: NodeName,
};

fn part1(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var map = std.StringHashMap(Fork).init(allocator);

    var it = std.mem.tokenizeScalar(u8, input, '\n');
    var directions: []const u8 = undefined;
    var first = true;
    while (it.next()) |line| {
        if (first) {
            directions = line;
            first = false;
        } else if (line.len > 0) {
            const key = line[0..3];
            const left = line[7..10];
            const right = line[12..15];
            try map.put(key, Fork{ .left = left, .right = right });
        }
    }

    var steps: usize = 0;
    var node: NodeName = "AAA";
    const goal: NodeName = "ZZZ";

    while (!std.mem.eql(u8, node, goal)) {
        const fork = map.get(node).?;
        const direction = directions[steps % directions.len];
        if (direction == 'L') {
            node = fork.left;
        } else {
            node = fork.right;
        }
        steps += 1;
    }

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), steps, std.fmt.fmtDuration(timer.read()) });
}

fn part2(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var map = std.StringHashMap(Fork).init(allocator);
    var startingNodes = std.ArrayList(NodeName).init(allocator);

    var it = std.mem.tokenizeScalar(u8, input, '\n');
    var directions: []const u8 = undefined;
    var first = true;
    while (it.next()) |line| {
        if (first) {
            directions = line;
            first = false;
        } else if (line.len > 0) {
            const key = line[0..3];
            const left = line[7..10];
            const right = line[12..15];
            try map.put(key, Fork{ .left = left, .right = right });
            if (key[2] == 'A') {
                try startingNodes.append(key);
            }
        }
    }

    // Nodes all loop at different frequencies.
    // We calculate the steps for each loop and calculate the least common multiple.
    var lcm: usize = 1;
    for (startingNodes.items) |startNode| {
        var steps: usize = 0;
        var node = startNode;
        while (true) {
            if (node[2] == 'Z') {
                break;
            }
            const fork = map.get(node).?;
            const direction = directions[steps % directions.len];
            if (direction == 'L') {
                node = fork.left;
            } else {
                node = fork.right;
            }
            steps += 1;
        }
        lcm = lcm * (steps / std.math.gcd(lcm, steps));
    }

    std.debug.print("Part 2 {s} {d} {d}\n", .{ std.fs.path.basename(name), lcm, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/08/example.txt");
    try part1("2023/08/input.txt");
    try part2("2023/08/example2.txt");
    try part2("2023/08/input.txt");
}
