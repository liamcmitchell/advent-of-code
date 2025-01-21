const std = @import("std");

const cardOrder: []const u8 = "AKQJT98765432";
const cardOrderJoker: []const u8 = "AKQT98765432J";

fn handScore(cards: []const u8, order: []const u8, withJoker: bool) u8 {
    var counts = [_]u8{0} ** cardOrder.len;

    for (cards) |card| {
        const index = std.mem.indexOfScalar(u8, order, card);
        counts[index.?] += 1;
    }

    var jokers: u8 = 0;
    if (withJoker) {
        const jokerIndex = std.mem.indexOfScalar(u8, order, 'J').?;
        jokers = counts[jokerIndex];
        counts[jokerIndex] = 0;
    }

    const primaryIndex = std.mem.indexOfMax(u8, &counts);
    const primary = counts[primaryIndex] + jokers;
    counts[primaryIndex] = 0;
    const secondary = std.mem.max(u8, &counts);

    if (primary == 5) {
        return 0;
    } else if (primary == 4) {
        return 1;
    } else if (primary == 3 and secondary == 2) {
        return 2;
    } else if (primary == 3) {
        return 3;
    } else if (primary == 2 and secondary == 2) {
        return 4;
    } else if (primary == 2) {
        return 5;
    } else {
        return 6;
    }
}

const Hand = struct {
    cards: []const u8,
    bid: usize,
    score: u8,
};

fn compareHands(order: []const u8, a: Hand, b: Hand) bool {
    if (a.score != b.score) {
        return a.score < b.score;
    } else {
        for (a.cards, b.cards) |cardA, cardB| {
            if (cardA != cardB) {
                const cardAValue = std.mem.indexOfScalar(u8, order, cardA);
                const cardBValue = std.mem.indexOfScalar(u8, order, cardB);
                return cardAValue.? < cardBValue.?;
            }
        }
    }
    return false;
}

fn part1(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var hands = std.ArrayList(Hand).init(allocator);

    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        const cards = line[0..5];
        const bid = try std.fmt.parseInt(usize, line[6..], 10);
        const score = handScore(cards, cardOrder, false);
        try hands.append(Hand{ .cards = cards, .bid = bid, .score = score });
    }

    std.mem.sort(Hand, hands.items, cardOrder, compareHands);

    var total: usize = 0;
    for (hands.items, 0..) |hand, index| {
        total += hand.bid * (hands.items.len - index);
    }

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

fn part2(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const input = try std.fs.cwd().readFileAlloc(allocator, name, std.math.maxInt(usize));
    var timer = try std.time.Timer.start();

    var hands = std.ArrayList(Hand).init(allocator);

    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        const cards = line[0..5];
        const bid = try std.fmt.parseInt(usize, line[6..], 10);
        const score = handScore(cards, cardOrderJoker, true);
        try hands.append(Hand{ .cards = cards, .bid = bid, .score = score });
    }

    std.mem.sort(Hand, hands.items, cardOrderJoker, compareHands);

    var total: usize = 0;
    for (hands.items, 0..) |hand, index| {
        total += hand.bid * (hands.items.len - index);
    }

    std.debug.print("Part 2 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/07/example.txt");
    try part1("2023/07/input.txt");
    try part2("2023/07/example.txt");
    try part2("2023/07/input.txt");
}
