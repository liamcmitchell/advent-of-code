local function part1(name)
	local count = 0
	for line in io.lines(name) do
		local ten = 0
		local one = 0
		for char in string.gmatch(line, "%d") do
			local n = tonumber(char) or 0
			if one > ten then
				ten = one
				one = n
			elseif n > one then
				one = n
			end
		end
		count = count + ten * 10 + one
	end
	print("Part 1 " .. name .. " " .. count)
end

local function part2(name)
	local count = 0
	for line in io.lines(name) do
		local bank = {}
		for char in string.gmatch(line, "%d") do
			table.insert(bank, tonumber(char))
		end
		local joltage = ""
		local len = 12
		local lastused = 0
		while #joltage < len do
			local max = 0
			local maxpos = 1
			for j = lastused + 1, #bank - (len - #joltage - 1) do
				local n = bank[j]
				if n > max then
					max = n
					maxpos = j
				end
			end
			joltage = joltage .. max
			lastused = maxpos
		end
		count = count + tonumber(joltage)
	end
	print("Part 2 " .. name .. " " .. count)
end

part1("2025/03/example.txt")
part1("2025/03/input.txt")
part2("2025/03/example.txt")
part2("2025/03/input.txt")
