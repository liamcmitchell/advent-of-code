const std = @import("std");

const Name = []const u8;

const Component = struct {
    name: Name,
    links: ComponentSet,

    pub fn init(allocator: std.mem.Allocator, name: Name) Component {
        return Component{ .name = name, .links = ComponentSet.init(allocator) };
    }
};

const ComponentSet = std.AutoHashMap(*Component, void);
const ComponentMap = std.StringHashMap(*Component);

const Link = struct {
    a: *Component,
    b: *Component,
    dist: usize = 0,
};

fn loopDistance(allocator: std.mem.Allocator, a: *Component, b: *Component) !usize {
    var visited = ComponentSet.init(allocator);
    defer visited.deinit();
    const Path = struct {
        component: *Component,
        distance: u8,
    };
    const Queue = std.fifo.LinearFifo(Path, .Dynamic);
    var queue: Queue = Queue.init(allocator);
    defer queue.deinit();
    try queue.writeItem(.{ .component = b, .distance = 0 });
    while (queue.readItem()) |path| {
        if (visited.contains(path.component)) continue;
        try visited.put(path.component, {});
        var linkIt = path.component.links.keyIterator();
        while (linkIt.next()) |nextPtr| {
            const next = nextPtr.*;
            if (next == a) {
                if (path.distance == 0) continue;
                return path.distance + 1;
            }
            try queue.writeItem(.{ .component = next, .distance = path.distance + 1 });
        }
    }
    return 999;
}

fn compareLinkDist(_: void, a: Link, b: Link) bool {
    return a.dist > b.dist;
}

fn connectedCount(allocator: std.mem.Allocator, start: *Component) !usize {
    var visited = ComponentSet.init(allocator);
    defer visited.deinit();
    const Queue = std.fifo.LinearFifo(*Component, .Dynamic);
    var queue: Queue = Queue.init(allocator);
    defer queue.deinit();
    try queue.writeItem(start);
    while (queue.readItem()) |component| {
        if (visited.contains(component)) continue;
        try visited.put(component, {});
        var linkIt = component.links.keyIterator();
        while (linkIt.next()) |next| {
            try queue.writeItem(next.*);
        }
    }
    return visited.count();
}

fn part1(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stat = try std.fs.cwd().statFile(name);
    const input = try std.fs.cwd().readFileAlloc(allocator, name, stat.size);
    var timer = try std.time.Timer.start();

    var componentCount: usize = 0;
    var componentList: [1500]Component = undefined;
    var componentMap = ComponentMap.init(allocator);
    var links = std.ArrayList(Link).init(allocator);
    var lineIt = std.mem.tokenizeScalar(u8, input, '\n');
    while (lineIt.next()) |line| {
        var nameIt = std.mem.tokenizeAny(u8, line, ": ");
        const aName = nameIt.next().?;
        const aResult = try componentMap.getOrPut(aName);
        if (!aResult.found_existing) {
            aResult.value_ptr.* = &componentList[componentCount];
            componentList[componentCount] = Component.init(allocator, aName);
            componentCount += 1;
        }
        const a = aResult.value_ptr.*;
        while (nameIt.next()) |bName| {
            const bResult = try componentMap.getOrPut(bName);
            if (!bResult.found_existing) {
                bResult.value_ptr.* = &componentList[componentCount];
                componentList[componentCount] = Component.init(allocator, bName);
                componentCount += 1;
            }
            const b = bResult.value_ptr.*;
            try a.links.put(b, {});
            try b.links.put(a, {});
            try links.append(Link{ .a = a, .b = b });
        }
    }

    for (links.items) |*link| {
        link.dist = try loopDistance(allocator, link.a, link.b);
    }
    std.mem.sort(Link, links.items, {}, compareLinkDist);
    for (links.items[0..3]) |link| {
        _ = link.a.links.remove(link.b);
        _ = link.b.links.remove(link.a);
    }
    const aCount = try connectedCount(allocator, &componentList[0]);
    const bCount = componentCount - aCount;
    const total = aCount * bCount;

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/25/example.txt");
    try part1("2023/25/input.txt");
}
