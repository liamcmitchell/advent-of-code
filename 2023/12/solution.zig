const std = @import("std");

fn arrangements(cache: *std.AutoHashMap(usize, usize), record: []const u8, groups: []usize, last: u8, expectingDamaged: usize) !usize {
    if (record.len == 0) {
        if (groups.len == 0 and expectingDamaged == 0) {
            return 1;
        } else {
            return 0;
        }
    }

    const lastKey: usize = if (last == '#') 1 else 0;
    const key = (record.len) + (groups.len << 8) + (lastKey << 16) + (expectingDamaged << 32);

    if (!cache.contains(key)) {
        const result = result: {
            const spring = record[0];

            var damaged: usize = 0;
            if (spring != '.') {
                if (expectingDamaged > 0) {
                    // Continue damaged group.
                    damaged = try arrangements(cache, record[1..], groups, '#', expectingDamaged - 1);
                } else if (groups.len > 0 and last != '#') {
                    // Start new group.
                    damaged = try arrangements(cache, record[1..], groups[1..], '#', groups[0] - 1);
                }
            }

            var undamaged: usize = 0;
            if (spring != '#' and expectingDamaged == 0) {
                undamaged = try arrangements(cache, record[1..], groups, '.', 0);
            }

            break :result damaged + undamaged;
        };

        try cache.put(key, result);
    }

    return cache.get(key).?;
}

fn part1(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var total: usize = 0;
    var cache = std.AutoHashMap(usize, usize).init(allocator);
    var groups = try std.ArrayList(usize).initCapacity(allocator, 10);
    var lineIt = std.mem.tokenizeScalar(u8, input, '\n');
    while (lineIt.next()) |line| {
        cache.clearRetainingCapacity();
        groups.clearRetainingCapacity();
        const springsCount = std.mem.indexOfScalar(u8, line, ' ').?;
        const record = line[0..springsCount];

        var groupIt = std.mem.tokenizeScalar(u8, line[springsCount + 1 ..], ',');
        while (groupIt.next()) |group| {
            const groupSize = try std.fmt.parseInt(usize, group, 10);
            try groups.append(groupSize);
        }

        total += try arrangements(&cache, record, groups.items, '.', 0);
    }

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

fn part2(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var total: usize = 0;
    var cache = std.AutoHashMap(usize, usize).init(allocator);
    var record = try std.ArrayList(u8).initCapacity(allocator, 100);
    var groups = try std.ArrayList(usize).initCapacity(allocator, 50);
    var lineIt = std.mem.tokenizeScalar(u8, input, '\n');
    while (lineIt.next()) |line| {
        cache.clearRetainingCapacity();
        record.clearRetainingCapacity();
        groups.clearRetainingCapacity();

        const springsCount = std.mem.indexOfScalar(u8, line, ' ').?;

        try record.appendSlice(line[0..springsCount]);

        var groupIt = std.mem.tokenizeScalar(u8, line[springsCount + 1 ..], ',');
        while (groupIt.next()) |group| {
            const groupSize = try std.fmt.parseInt(usize, group, 10);
            try groups.append(groupSize);
        }
        const groupsCount = groups.items.len;

        const folds = 5;

        for (1..folds) |_| {
            try record.append('?');
            try record.appendSlice(line[0..springsCount]);
            try groups.appendSlice(groups.items[0..groupsCount]);
        }

        total += try arrangements(&cache, record.items, groups.items, '.', 0);
    }

    std.debug.print("Part 2 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/12/example.txt");
    try part1("2023/12/input.txt");
    try part2("2023/12/example.txt");
    try part2("2023/12/input.txt");
}
