const std = @import("std");

fn hash(input: []const u8) u8 {
    var value: u8 = 0;
    for (input) |char| {
        value = @truncate((@as(u16, value) + @as(u16, char)) * 17);
    }
    return value;
}

fn part1(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var total: usize = 0;
    var commaIt = std.mem.tokenizeScalar(u8, input, ',');
    while (commaIt.next()) |step| {
        total += hash(step);
    }

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

const Lense = struct { label: []const u8 = "", focalLength: u8 = 0, next: ?*Lense = null };

fn part2(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var boxes: [256]Lense = [_]Lense{Lense{}} ** 256;
    var commaIt = std.mem.tokenizeScalar(u8, input, ',');
    while (commaIt.next()) |step| {
        if (step[step.len - 1] == '-') {
            const label = step[0 .. step.len - 1];
            var prev = &boxes[hash(label)];
            var next = prev.next;
            while (next) |lense| {
                if (std.mem.eql(u8, lense.label, label)) {
                    prev.next = lense.next;
                    break;
                } else {
                    prev = lense;
                    next = lense.next;
                }
            }
        } else {
            const equals = std.mem.indexOfScalar(u8, step, '=').?;
            const label = step[0..equals];
            const focalLength = try std.fmt.parseInt(u8, step[equals + 1 ..], 10);
            var prev = &boxes[hash(label)];
            var next = prev.next;
            var found = false;
            while (next) |lense| {
                if (std.mem.eql(u8, lense.label, label)) {
                    found = true;
                    lense.focalLength = focalLength;
                    break;
                } else {
                    prev = lense;
                    next = lense.next;
                }
            }
            if (!found) {
                const new = try allocator.create(Lense);
                new.* = .{ .label = label, .focalLength = focalLength };
                prev.next = new;
            }
        }
    }

    var total: usize = 0;
    for (boxes, 1..) |start, box| {
        var maybeLense = start.next;
        var slot: usize = 0;
        while (maybeLense) |lense| {
            slot += 1;
            total += box * slot * lense.focalLength;
            maybeLense = lense.next;
        }
    }

    std.debug.print("Part 2 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/15/example.txt");
    try part1("2023/15/input.txt");
    try part2("2023/15/example.txt");
    try part2("2023/15/input.txt");
}
