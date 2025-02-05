const std = @import("std");

fn arrangements(cache: *std.AutoHashMap(usize, usize), record: []const u8, groups: []usize, last: u8, expectingDamaged: usize, remainingDamaged: usize, remainingKnownDamaged: usize) !usize {
    const lastKey: usize = if (last == '#') 1 else 0;
    const key = (record.len) + (groups.len * 100) + (lastKey * 10000) + (expectingDamaged * 100000);

    if (!cache.contains(key)) {
        const result = result: {
            if (record.len < (remainingDamaged + @max(groups.len, 1) - 1)) {
                // Arrangement not possible.
                // std.debug.print("not possible {s} {d} {d} {d}\n", .{ record, expectingDamaged, remainingDamaged, groups.len });
                break :result 0;
            } else if (record.len == 0) {
                break :result 1;
            }

            switch (record[0]) {
                '#' => {
                    if (expectingDamaged == 0 and last == '#') {
                        // We can't start a new group immediately after the last.
                        break :result 0;
                    }

                    if (expectingDamaged > 0) {
                        break :result try arrangements(cache, record[1..], groups, '#', expectingDamaged - 1, remainingDamaged - 1, remainingKnownDamaged - 1);
                    }

                    // Starting a new group.
                    break :result try arrangements(cache, record[1..], groups[1..], '#', groups[0] - 1, remainingDamaged - 1, remainingKnownDamaged - 1);
                },
                '.' => {
                    if (expectingDamaged > 0) {
                        break :result 0;
                    }

                    break :result try arrangements(cache, record[1..], groups, '.', expectingDamaged, remainingDamaged, remainingKnownDamaged);
                },
                '?' => {
                    if (expectingDamaged > 0) {
                        if (remainingDamaged == remainingKnownDamaged) {
                            // Can't mark any more as damaged.
                            break :result 0;
                        }

                        break :result try arrangements(cache, record[1..], groups, '#', expectingDamaged - 1, remainingDamaged - 1, remainingKnownDamaged);
                    }

                    if (last == '#' or remainingDamaged == remainingKnownDamaged) {
                        // This should not be damaged.
                        break :result try arrangements(cache, record[1..], groups, '.', expectingDamaged, remainingDamaged, remainingKnownDamaged);
                    }

                    if (record.len == (remainingDamaged + @max(groups.len, 1) - 1)) {
                        // We don't have a choice, the remaining must be damaged.
                        break :result try arrangements(cache, record[1..], groups[1..], '#', groups[0] - 1, remainingDamaged - 1, remainingKnownDamaged);
                    }

                    // Could be damaged or not.
                    const asDamaged = try arrangements(cache, record[1..], groups[1..], '#', groups[0] - 1, remainingDamaged - 1, remainingKnownDamaged);
                    const asUndamaged = try arrangements(cache, record[1..], groups, '.', expectingDamaged, remainingDamaged, remainingKnownDamaged);
                    break :result asDamaged + asUndamaged;
                },
                else => unreachable,
            }
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

        var damagedCount: usize = 0;
        for (groups.items) |groupSize| damagedCount += groupSize;

        const knownDamagedCount = std.mem.count(u8, record, "#");

        total += try arrangements(&cache, record, groups.items, '.', 0, damagedCount, knownDamagedCount);
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

        var damagedCount: usize = 0;
        for (groups.items) |groupSize| damagedCount += groupSize;

        const knownDamagedCount = std.mem.count(u8, record.items, "#");

        const folds = 5;

        for (1..folds) |_| {
            try record.append('?');
            try record.appendSlice(line[0..springsCount]);
            try groups.appendSlice(groups.items[0..groupsCount]);
        }

        total += try arrangements(&cache, record.items, groups.items, '.', 0, damagedCount * folds, knownDamagedCount * folds);
    }

    std.debug.print("Part 2 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/12/example.txt");
    try part1("2023/12/input.txt");
    try part2("2023/12/example.txt");
    try part2("2023/12/input.txt");
}
