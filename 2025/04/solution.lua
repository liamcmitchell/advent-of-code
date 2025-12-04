local function parse(name)
	local map = {}
	local padding = 1
	local width = 0
	local i = 0
	for line in io.lines(name) do
		if width == 0 then
			width = #line + (padding * 2)
			i = width * padding
		end
		i = i + padding * 2
		for char in string.gmatch(line, ".") do
			if char == "@" then
				map[i] = true
			end
			i = i + 1
		end
	end
	return map, width
end

local function part1(name)
	local map, width = parse(name)
	local directions = { -width, -width + 1, 1, width + 1, width, width - 1, -1, -width - 1 }
	local count = 0
	for i in pairs(map) do
		local rolls = 0
		for _, d in ipairs(directions) do
			if map[i + d] then
				rolls = rolls + 1
			end
		end
		if rolls < 4 then
			count = count + 1
		end
	end
	print("Part 1 " .. name .. " " .. count)
end

local function part2(name)
	local map, width = parse(name)
	local directions = { -width, -width + 1, 1, width + 1, width, width - 1, -1, -width - 1 }
	local count = 0
	while true do
		local remove = {}
		for i in pairs(map) do
			local rolls = 0
			for _, d in ipairs(directions) do
				if map[i + d] then
					rolls = rolls + 1
				end
			end
			if rolls < 4 then
				table.insert(remove, i)
			end
		end
		if #remove == 0 then
			break
		end
		for _, i in ipairs(remove) do
			map[i] = nil
		end
		count = count + #remove
	end
	print("Part 2 " .. name .. " " .. count)
end

part1("2025/04/example.txt")
part1("2025/04/input.txt")
part2("2025/04/example.txt")
part2("2025/04/input.txt")
