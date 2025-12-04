local function invalids(first, last, maxduplicates)
	local count = 0
	local duplicates = 2
	local found = {}
	while duplicates <= maxduplicates do
		local fn = 0
		if #first % duplicates ~= 0 then
			fn = tonumber("1" .. string.rep("0", math.floor(#first / duplicates))) or 0
		else
			fn = tonumber(string.sub(first, 1, #first / duplicates)) or 0
			if string.rep(fn, duplicates) < first then
				fn = fn + 1
			end
		end
		local ln = 0
		if #last % duplicates ~= 0 then
			ln = tonumber(string.rep("9", math.floor((#last - 1) / duplicates))) or 0
		else
			ln = tonumber(string.sub(last, 1, #last / duplicates)) or 0
			if string.rep(ln, duplicates) > last then
				ln = ln - 1
			end
		end
		while fn <= ln do
			local n = string.rep(tostring(fn), duplicates)
			if found[n] == nil then
				found[n] = true
				count = count + tonumber(n)
			end
			fn = fn + 1
		end
		duplicates = duplicates + 1
	end
	return count
end

local function part1(name)
	local input = io.open(name):read("a")
	local count = 0
	for first, last in string.gmatch(input, "(%d+)-(%d+)") do
		count = count + invalids(first, last, 2)
	end
	print("Part 1 " .. name .. " " .. count)
end

local function part2(name)
	local input = io.open(name):read("a")
	local count = 0
	for first, last in string.gmatch(input, "(%d+)-(%d+)") do
		count = count + invalids(first, last, math.max(#first, #last))
	end
	print("Part 2 " .. name .. " " .. count)
end

part1("2025/02/example.txt")
part1("2025/02/input.txt")
part2("2025/02/example.txt")
part2("2025/02/input.txt")
