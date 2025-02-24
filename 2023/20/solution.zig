const std = @import("std");

const Name = []const u8;

const Names = std.ArrayList(Name);

const ModuleType = enum {
    flipFlop,
    conjunction,
    broadcaster,
};

const Module = struct {
    type: ModuleType,
    name: Name,
    destinations: Names,
    inputs: Names,
    index: u8 = 0,
    reset: usize = 0,
};

const Modules = std.StringHashMap(Module);

const Pulse = struct {
    origin: Name,
    high: bool = false,
    dest: Name,
};

const Pulses = std.fifo.LinearFifo(Pulse, .Dynamic);

fn parseModules(allocator: std.mem.Allocator, input: []const u8) !Modules {
    var modules = Modules.init(allocator);
    var lineIt = std.mem.tokenizeScalar(u8, input, '\n');
    while (lineIt.next()) |line| {
        var partIt = std.mem.tokenizeAny(u8, line, " ->,");
        const first = partIt.next().?;
        const moduleName = if (first[0] == 'b') first else first[1..];
        var module = Module{
            .type = switch (first[0]) {
                '%' => .flipFlop,
                '&' => .conjunction,
                else => .broadcaster,
            },
            .name = moduleName,
            .destinations = Names.init(allocator),
            .inputs = Names.init(allocator),
        };
        while (partIt.next()) |dest| try module.destinations.append(dest);
        try modules.put(moduleName, module);
    }

    var moduleIt = modules.iterator();

    // Fill in module inputs.
    while (moduleIt.next()) |entry| {
        const module = entry.value_ptr;
        for (module.destinations.items) |dest| {
            const destModule = modules.getPtr(dest) orelse continue;
            try destModule.inputs.append(module.name);
        }
    }

    // Set index for module memory.
    var memoryIndex: u8 = 0;
    moduleIt = modules.iterator();
    while (moduleIt.next()) |entry| {
        const module = entry.value_ptr;
        module.index = memoryIndex;
        memoryIndex += @intCast(module.inputs.items.len);
    }

    return modules;
}

fn part1(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stat = try std.fs.cwd().statFile(name);
    const input = try std.fs.cwd().readFileAlloc(allocator, name, stat.size);
    var timer = try std.time.Timer.start();

    var modules = try parseModules(allocator, input);

    var memory = try allocator.alloc(bool, modules.count() * 5);
    @memset(memory, false);

    var pulses: Pulses = Pulses.init(allocator);
    var lowPulses: usize = 0;
    var highPulses: usize = 0;

    for (0..1000) |_| {
        try pulses.writeItem(Pulse{ .origin = "button", .high = false, .dest = "broadcaster" });

        while (pulses.readItem()) |pulse| {
            if (pulse.high) highPulses += 1 else lowPulses += 1;
            // std.debug.print("{s} -{s}-> {s}\n", .{ pulse.origin, if (pulse.high) "high" else "low", pulse.dest });
            const module = modules.get(pulse.dest) orelse continue;
            switch (module.type) {
                .flipFlop => {
                    if (!pulse.high) {
                        const newState = !memory[module.index];
                        memory[module.index] = newState;
                        for (module.destinations.items) |dest| {
                            try pulses.writeItem(Pulse{ .origin = module.name, .high = newState, .dest = dest });
                        }
                    }
                },
                .conjunction => {
                    var allHigh = true;
                    for (module.inputs.items, 0..) |in, i| {
                        if (in.ptr == pulse.origin.ptr) {
                            memory[module.index + i] = pulse.high;
                        }
                        allHigh = allHigh and memory[module.index + i];
                    }
                    for (module.destinations.items) |dest| {
                        try pulses.writeItem(Pulse{ .origin = module.name, .high = !allHigh, .dest = dest });
                    }
                },
                .broadcaster => {
                    for (module.destinations.items) |dest| {
                        try pulses.writeItem(Pulse{ .origin = module.name, .high = pulse.high, .dest = dest });
                    }
                },
            }
        }
    }

    const total = lowPulses * highPulses;

    std.debug.print("Part 1 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

fn part2(name: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const stat = try std.fs.cwd().statFile(name);
    const input = try std.fs.cwd().readFileAlloc(allocator, name, stat.size);
    var timer = try std.time.Timer.start();

    var modules = try parseModules(allocator, input);

    var memory = try allocator.alloc(bool, modules.count() * 5);
    @memset(memory, false);

    var pulses: Pulses = Pulses.init(allocator);

    // Debugging showed that rx would recieve a low pulse when a single low pulse from 4x & modules aligned.
    // Each of the & modules emits it's low a the end of a slighly different length cycle.
    // Pressing the button 5000 times is enough to find the length of these 4 cycles.
    for (1..5000) |press| {
        try pulses.writeItem(Pulse{ .origin = "button", .high = false, .dest = "broadcaster" });

        while (pulses.readItem()) |pulse| {
            const module = modules.getPtr(pulse.dest) orelse continue;
            switch (module.type) {
                .flipFlop => {
                    if (!pulse.high) {
                        const newState = !memory[module.index];
                        memory[module.index] = newState;
                        for (module.destinations.items) |dest| {
                            try pulses.writeItem(Pulse{ .origin = module.name, .high = newState, .dest = dest });
                        }
                    }
                },
                .conjunction => {
                    var allHigh = true;
                    var allLow = true;
                    for (module.inputs.items, 0..) |in, i| {
                        if (in.ptr == pulse.origin.ptr) {
                            memory[module.index + i] = pulse.high;
                        }
                        allHigh = allHigh and memory[module.index + i];
                        allLow = allLow and !memory[module.index + i];
                    }
                    // Record when this module cycle resets.
                    if (allLow and module.reset == 0 and press != 0) {
                        module.reset = press;
                    }
                    for (module.destinations.items) |dest| {
                        try pulses.writeItem(Pulse{ .origin = module.name, .high = !allHigh, .dest = dest });
                    }
                },
                .broadcaster => {
                    for (module.destinations.items) |dest| {
                        try pulses.writeItem(Pulse{ .origin = module.name, .high = pulse.high, .dest = dest });
                    }
                },
            }
        }
    }

    // The total is then the least common multiple of the 4 cycles.
    var total: usize = 1;
    const zg = modules.get("zg").?;
    for (zg.inputs.items) |n| {
        const inputModule = modules.get(n).?;
        total = total * (inputModule.reset / std.math.gcd(total, inputModule.reset));
    }

    std.debug.print("Part 2 {s} {d} {d}\n", .{ std.fs.path.basename(name), total, std.fmt.fmtDuration(timer.read()) });
}

pub fn main() !void {
    try part1("2023/20/example1.txt");
    try part1("2023/20/example2.txt");
    try part1("2023/20/input.txt");
    try part2("2023/20/input.txt");
}
