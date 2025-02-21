const std = @import("std");

const Score = u12;
const minScore = 1;
const maxScore = 4001;

const Name = []const u8;

const Part = [4]Score;

const Range = struct {
    // Inclusive min.
    min: Score = minScore,
    // Exclusive max.
    max: Score = maxScore,
};

const Ranges = [4]Range;

const Rule = struct {
    destination: Name,
    ranges: Ranges = .{Range{}} ** 4,
};

const Workflow = []Rule;

fn part1(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var workflows = std.StringHashMap(Workflow).init(allocator);
    var parts = std.ArrayList(Part).init(allocator);
    var lineIt = std.mem.tokenizeScalar(u8, input, '\n');
    while (lineIt.next()) |line| {
        if (line[0] != '{') {
            var workflowIt = std.mem.tokenizeAny(u8, line, "{,}");
            var rules = std.ArrayList(Rule).init(allocator);
            const workflowName = workflowIt.next().?;
            while (workflowIt.next()) |ruleText| {
                if (std.mem.indexOfScalar(u8, ruleText, ':')) |colon| {
                    const score = try std.fmt.parseInt(Score, ruleText[2..colon], 10);
                    const range = if (ruleText[1] == '<') Range{ .max = score } else Range{ .min = score + 1 };
                    var rule = Rule{
                        .destination = ruleText[colon + 1 ..],
                    };
                    rule.ranges[std.mem.indexOfScalar(u8, "xmas", ruleText[0]).?] = range;
                    try rules.append(rule);
                } else {
                    try rules.append(Rule{
                        .destination = ruleText,
                    });
                    try workflows.put(workflowName, rules.items);
                }
            }
        } else {
            var partIt = std.mem.tokenizeScalar(u8, line[1 .. line.len - 1], ',');
            var part: Part = undefined;
            for (0..4) |i| part[i] = try std.fmt.parseInt(Score, partIt.next().?[2..], 10);
            try parts.append(part);
        }
    }

    var total: usize = 0;
    parts: for (parts.items) |part| {
        var workflow = workflows.get("in").?;
        workflow: while (true) {
            rules: for (workflow) |rule| {
                for (rule.ranges, part) |range, score| {
                    if (score < range.min or score >= range.max) {
                        continue :rules;
                    }
                }

                switch (rule.destination[0]) {
                    'R' => {
                        continue :parts;
                    },
                    'A' => {
                        for (part) |score| total += score;
                        continue :parts;
                    },
                    else => {
                        workflow = workflows.get(rule.destination).?;
                        continue :workflow;
                    },
                }
            }
        }
    }

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

fn combinations(workflows: std.StringHashMap(Workflow), workflow: Workflow, ranges: Ranges) usize {
    if (workflow.len == 0) return 0;

    // For every rule, we create and modify matching/nonmatching ranges.
    const rule = workflow[0];
    var matchingRanges = ranges;
    var nonMatchingRanges = ranges;
    var matchingCombinations: usize = 1;
    var nonMatchingCombinations: usize = 1;

    for (rule.ranges, &matchingRanges, &nonMatchingRanges) |range, *matching, *nonMatching| {
        if (range.min != minScore) {
            matching.min = std.math.clamp(range.min, matching.min, matching.max);
            nonMatching.max = std.math.clamp(range.min, nonMatching.min, nonMatching.max);
        }
        if (range.max != maxScore) {
            matching.max = std.math.clamp(range.max, matching.min, matching.max);
            nonMatching.min = std.math.clamp(range.max, nonMatching.min, nonMatching.max);
        }
        matchingCombinations *= matching.max - matching.min;
        nonMatchingCombinations *= nonMatching.max - nonMatching.min;
    }

    const matchingTotal: usize = switch (rule.destination[0]) {
        'R' => 0,
        'A' => matchingCombinations,
        else => if (matchingCombinations == 0) 0 else combinations(workflows, workflows.get(rule.destination).?, matchingRanges),
    };

    const nonMatchingTotal = if (nonMatchingCombinations == 0) 0 else combinations(workflows, workflow[1..], nonMatchingRanges);

    return matchingTotal + nonMatchingTotal;
}

fn part2(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var workflows = std.StringHashMap(Workflow).init(allocator);
    var lineIt = std.mem.tokenizeScalar(u8, input, '\n');
    while (lineIt.next()) |line| {
        if (line[0] != '{') {
            var workflowIt = std.mem.tokenizeAny(u8, line, "{,}");
            var rules = std.ArrayList(Rule).init(allocator);
            const workflowName = workflowIt.next().?;
            while (workflowIt.next()) |ruleText| {
                if (std.mem.indexOfScalar(u8, ruleText, ':')) |colon| {
                    const score = try std.fmt.parseInt(Score, ruleText[2..colon], 10);
                    const range = if (ruleText[1] == '<') Range{ .max = score } else Range{ .min = score + 1 };
                    var rule = Rule{
                        .destination = ruleText[colon + 1 ..],
                    };
                    rule.ranges[std.mem.indexOfScalar(u8, "xmas", ruleText[0]).?] = range;
                    try rules.append(rule);
                } else {
                    try rules.append(Rule{
                        .destination = ruleText,
                    });
                    try workflows.put(workflowName, rules.items);
                }
            }
        }
    }

    const total = combinations(workflows, workflows.get("in").?, .{Range{}} ** 4);

    std.debug.print("Part 2 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/19/example.txt");
    try part1("2023/19/input.txt");
    try part2("2023/19/example.txt");
    try part2("2023/19/input.txt");
}
