const std = @import("std");

const Coord = struct {
    x: i16,
    y: i16,

    pub fn init(x: anytype, y: anytype) Coord {
        return Coord{ .x = @intCast(x), .y = @intCast(y) };
    }

    pub fn add(a: Coord, b: Coord) Coord {
        return Coord{ .x = a.x + b.x, .y = a.y + b.y };
    }

    pub fn equal(a: Coord, b: Coord) bool {
        return a.x == b.x and a.y == b.y;
    }

    pub fn valid(self: Coord, width: usize) bool {
        return self.x >= 0 and self.x < width and self.y >= 0 and self.y < width;
    }

    pub fn index(self: Coord, width: usize) usize {
        return @as(usize, @intCast(self.x)) + (@as(usize, @intCast(self.y)) * width);
    }
};

const directions = [4]Coord{ Coord.init(0, -1), Coord.init(1, 0), Coord.init(0, 1), Coord.init(-1, 0) };
const directionChars = "^>v<";

const CoordSet = std.AutoHashMap(Coord, void);

const Count = u16;

const Path = struct {
    start: Coord,
    end: Coord,
    count: Count = 0,
};
const PathQueue = std.fifo.LinearFifo(Path, .Dynamic);

const CoordCountMap = std.AutoHashMap(Coord, Count);
const CoordCoordCountMap = std.AutoHashMap(Coord, CoordCountMap);

fn part1(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stat = try std.fs.cwd().statFile(name);
    const input = try std.fs.cwd().readFileAlloc(allocator, name, stat.size);
    var timer = try std.time.Timer.start();

    const width = std.mem.indexOfScalar(u8, input, '\n').?;
    const start = Coord.init(1, 0);
    const end = Coord.init(width - 2, width - 1);

    var connections: CoordCoordCountMap = CoordCoordCountMap.init(allocator);
    var pathQueue: PathQueue = PathQueue.init(allocator);
    var pathSeen: CoordSet = CoordSet.init(allocator);

    try pathQueue.writeItem(Path{ .start = start, .end = start });
    try connections.put(start, CoordCountMap.init(allocator));

    while (pathQueue.readItem()) |path| {
        for (directions, directionChars) |d, dChar| {
            var next = path.end.add(d);

            if (!next.valid(width)) continue;

            const char = input[next.index(width + 1)];

            if (char == '#') continue;

            if (char != '.' and char != dChar) continue;

            if (pathSeen.contains(next)) continue;
            try pathSeen.put(next, {});

            var nextIsNode = false;
            var nextCount = path.count + 1;

            if (next.equal(end)) {
                nextIsNode = true;
            }

            if (path.count > 0 and char == dChar) {
                nextIsNode = true;
                next = next.add(d);
                nextCount += 1;
            }

            if (nextIsNode) {
                const distances: *CoordCountMap = connections.getPtr(path.start).?;
                try distances.put(next, nextCount);
                if (!connections.contains(next)) {
                    try connections.put(next, CoordCountMap.init(allocator));
                }
                try pathQueue.writeItem(Path{ .start = next, .end = next, .count = 0 });
            } else {
                try pathQueue.writeItem(Path{ .start = path.start, .end = next, .count = nextCount });
            }
        }
    }

    var total: Count = 0;
    try pathQueue.writeItem(Path{ .start = start, .end = start });
    while (pathQueue.readItem()) |path| {
        const distances: CoordCountMap = connections.get(path.end).?;
        var nodeIt = distances.iterator();
        while (nodeIt.next()) |entry| {
            const next = entry.key_ptr.*;
            const dist = path.count + entry.value_ptr.*;
            if (next.equal(end)) {
                total = @max(total, dist);
            } else {
                try pathQueue.writeItem(Path{ .start = path.start, .end = next, .count = dist });
            }
        }
    }

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

// Part 2 requires brute force of a much larger solution space.
// We optimize for runtime speed by using arrays instead of hashmaps and bitmasks instead of sets.

const NodeId = u6;
const NodeVisited = u36;

const CoordIdMap = std.AutoHashMap(Coord, NodeId);

const Neighbour = struct {
    id: NodeId,
    count: Count,
};

const Node = struct {
    neighbourLen: u3 = 0,
    neighbours: [4]Neighbour = undefined,
};

const Nodes = [36]Node;

const NodePath = struct {
    id: NodeId,
    visited: NodeVisited,
    count: Count,
};

const NodePathQueue = std.fifo.LinearFifo(NodePath, .Dynamic);

fn part2(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stat = try std.fs.cwd().statFile(name);
    const input = try std.fs.cwd().readFileAlloc(allocator, name, stat.size);
    var timer = try std.time.Timer.start();

    const width = std.mem.indexOfScalar(u8, input, '\n').?;
    const start = Coord.init(1, 0);
    const end = Coord.init(width - 2, width - 1);

    var coordIds = CoordIdMap.init(allocator);
    var nodes: Nodes = undefined;
    nodes[0] = Node{};
    try coordIds.put(start, 0);
    var nodeCount: NodeId = 1;

    var pathQueue: PathQueue = PathQueue.init(allocator);
    var pathSeen: CoordSet = CoordSet.init(allocator);
    try pathQueue.writeItem(Path{ .start = start, .end = start });

    while (pathQueue.readItem()) |path| {
        for (directions, directionChars) |d, dChar| {
            var next = path.end.add(d);

            if (!next.valid(width)) continue;

            const char = input[next.index(width + 1)];

            if (char == '#') continue;
            if (char != '.' and char != dChar) continue;

            if (pathSeen.contains(next)) continue;
            try pathSeen.put(next, {});

            var nextIsNode = false;
            var nextCount = path.count + 1;

            if (next.equal(end)) {
                nextIsNode = true;
            }

            if (path.count > 0 and char != '.') {
                nextIsNode = true;
                next = next.add(d);
                nextCount += 1;
            }

            if (nextIsNode) {
                const startId = coordIds.get(path.start).?;
                const startNode = &nodes[startId];

                if (!coordIds.contains(next)) {
                    try coordIds.put(next, nodeCount);
                    nodes[nodeCount] = Node{};
                    nodeCount += 1;
                }
                const endId = coordIds.get(next).?;
                const endNode = &nodes[endId];

                startNode.neighbours[startNode.neighbourLen] = Neighbour{ .id = endId, .count = nextCount };
                startNode.neighbourLen += 1;

                endNode.neighbours[endNode.neighbourLen] = Neighbour{ .id = startId, .count = nextCount };
                endNode.neighbourLen += 1;

                try pathQueue.writeItem(Path{ .start = next, .end = next, .count = 0 });
            } else {
                try pathQueue.writeItem(Path{ .start = path.start, .end = next, .count = nextCount });
            }
        }
    }

    var nodePathQueue: NodePathQueue = NodePathQueue.init(allocator);
    const endId = coordIds.get(end).?;

    // Shrink the problem space by removing paths that should never be taken.
    try nodePathQueue.writeItem(NodePath{ .id = 0, .visited = 0, .count = 0 });
    var optimized: NodeVisited = 0;
    while (nodePathQueue.readItem()) |path| {
        const mask = @as(NodeVisited, 1) << path.id;
        if (optimized & mask > 0) continue;
        optimized |= mask;

        const node = nodes[path.id];
        for (node.neighbours[0..node.neighbourLen]) |neighbour| {
            if (optimized & @as(NodeVisited, 1) << neighbour.id > 0) continue;

            const neighbourNode = &nodes[neighbour.id];
            // If node and neighbour both have 3 or fewer neighbours, this is an edge.
            if (node.neighbourLen <= 3 and neighbourNode.neighbourLen <= 3) {
                // Remove path backwards. This would result in a dead-end.
                var i: u2 = 0;
                var found = false;
                for (neighbourNode.neighbours[0..neighbourNode.neighbourLen]) |neighbourNeighbour| {
                    if (found) {
                        neighbourNode.neighbours[i - 1] = neighbourNode.neighbours[i];
                    } else if (neighbourNeighbour.id == path.id) {
                        neighbourNode.neighbourLen -= 1;
                        found = true;
                    }
                    i += 1;
                }
            }

            try nodePathQueue.writeItem(NodePath{ .id = neighbour.id, .visited = 0, .count = 0 });
        }
    }

    // Now iterate over all paths.
    var total: Count = 0;
    try nodePathQueue.writeItem(NodePath{ .id = 0, .visited = 0, .count = 0 });
    while (nodePathQueue.readItem()) |path| {
        if (path.id == endId) {
            total = @max(total, path.count);
            continue;
        }

        const visited = path.visited | @as(NodeVisited, 1) << path.id;
        const node = &nodes[path.id];

        for (node.neighbours[0..node.neighbourLen]) |neighbour| {
            if (visited & @as(NodeVisited, 1) << neighbour.id > 0) continue;
            try nodePathQueue.writeItem(NodePath{ .id = neighbour.id, .visited = visited, .count = path.count + neighbour.count });
        }
    }

    std.debug.print("Part 2 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/23/example.txt");
    try part1("2023/23/input.txt");
    try part2("2023/23/example.txt");
    try part2("2023/23/input.txt");
}
