local function part1(name)
	local count = 0
	local ranges = {}
	local input = io.open(name):read("*a")
	for a, b in string.gmatch(input, "(%d+)-?(%d*)") do
		if b ~= "" then
			table.insert(ranges, { tonumber(a), tonumber(b) })
		else
			local n = tonumber(a)
			for _, range in ipairs(ranges) do
				if range[1] <= n and range[2] >= n then
					count = count + 1
					break
				end
			end
		end
	end
	print("Part 1 " .. name .. " " .. count)
end

local function part2(name)
	local count = 0
	local ranges = {}
	local input = io.open(name):read("*a")
	for a, b in string.gmatch(input, "(%d+)-(%d+)") do
		table.insert(ranges, { tonumber(a), tonumber(b) })
	end
	table.sort(ranges, function(a, b)
		return a[1] < b[1]
	end)
	local i = 1
	while i < #ranges do
		local j = i + 1
		if ranges[i][2] >= ranges[j][1] then
			ranges[i][2] = math.max(ranges[i][2], ranges[j][2])
			table.remove(ranges, j)
		else
			i = i + 1
		end
	end
	for _, range in ipairs(ranges) do
		count = count + range[2] - range[1] + 1
	end
	print("Part 2 " .. name .. " " .. count)
end

part1("2025/05/example.txt")
part1("2025/05/input.txt")
part2("2025/05/example.txt")
part2("2025/05/input.txt")
