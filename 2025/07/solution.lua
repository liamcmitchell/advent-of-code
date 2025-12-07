local function part1(name)
	local count = 0
	local row = {}
	for line in io.lines(name) do
		local i = 0
		for char in string.gmatch(line, ".") do
			i = i + 1
			if char == "S" then
				row[i] = 1
			elseif char == "^" and row[i] == 1 then
				count = count + 1
				row[i] = 0
				row[i - 1] = 1
				row[i + 1] = 1
			end
		end
	end
	print("Part 1 " .. name .. " " .. count)
end

local function part2(name)
	local count = 0
	local row = {}
	for line in io.lines(name) do
		local i = 0
		for char in string.gmatch(line, ".") do
			i = i + 1
			if char == "S" then
				row[i] = 1
			elseif char == "^" and row[i] then
				row[i - 1] = (row[i - 1] or 0) + row[i]
				row[i + 1] = (row[i + 1] or 0) + row[i]
				row[i] = nil
			end
		end
	end
	for _, beams in pairs(row) do
		count = count + beams
	end
	print("Part 2 " .. name .. " " .. count)
end

part1("2025/07/example.txt")
part1("2025/07/input.txt")
part2("2025/07/example.txt")
part2("2025/07/input.txt")
