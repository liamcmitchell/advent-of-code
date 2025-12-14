local function parse(name)
	local devices = {}
	for line in io.lines(name) do
		local i = 0
		local device
		for label in string.gmatch(line, "%a+") do
			i = i + 1
			if not devices[label] then
				devices[label] = {}
			end
			if i == 1 then
				device = devices[label]
			else
				table.insert(device, devices[label])
			end
		end
	end
	return devices
end

local function part1(name)
	local start = os.clock()
	local result = 0
	local devices = parse(name)
	local you = devices["you"]
	local out = devices["out"]
	local function paths(device)
		if device == out then
			return 1
		end
		local total = 0
		for _, d in ipairs(device) do
			total = total + paths(d)
		end
		return total
	end
	result = paths(you)
	print("Part 1 " .. name .. " " .. result .. " in " .. string.format("%.3f", os.clock() - start))
end

local function part2(name)
	local start = os.clock()
	local result = 0
	local devices = parse(name)
	local svr = devices["svr"]
	local dac = devices["dac"]
	local fft = devices["fft"]
	local out = devices["out"]
	local foundnothing = 1
	local founddac = 2
	local foundfft = 3
	local foundboth = 4
	local cache = { {}, {}, {}, {} }
	local function paths(device, state)
		if device == out then
			if state == foundboth then
				return 1
			else
				return 0
			end
		end
		if device == dac then
			if state == foundfft then
				state = foundboth
			else
				state = founddac
			end
		end
		if device == fft then
			if state == founddac then
				state = foundboth
			else
				state = foundfft
			end
		end
		local cached = cache[state][device]
		if cached then
			return cached
		end
		local total = 0
		for _, d in ipairs(device) do
			total = total + paths(d, state)
		end
		cache[state][device] = total
		return total
	end
	result = paths(svr, foundnothing)
	print(
		"Part 2 " .. name .. " " .. string.format("%d", result) .. " in " .. string.format("%.3f", os.clock() - start)
	)
end

part1("2025/11/example.txt")
part1("2025/11/input.txt")
part2("2025/11/example2.txt")
part2("2025/11/input.txt")
