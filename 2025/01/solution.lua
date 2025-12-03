local function part1(name)
	local dial = 50
	local count = 0
	for line in io.lines(name, "l") do
		dial = dial + (string.sub(line, 1, 1) == "L" and -1 or 1) * tonumber(string.sub(line, 2))
		dial = dial % 100
		if dial == 0 then
			count = count + 1
		end
	end
	print("Part 1 " .. name .. " " .. count)
end

local function part2(name)
	local dial = 50
	local count = 0
	for line in io.lines(name, "l") do
		local direction = string.sub(line, 1, 1) == "L" and -1 or 1
		local after = dial + direction * tonumber(string.sub(line, 2))
		local zeroes = 0
		if direction == 1 then
			zeroes = math.floor(after / 100) - math.floor(dial / 100)
		else
			zeroes = math.ceil(dial / 100) - math.ceil(after / 100)
		end
		count = count + zeroes
		dial = after % 100
	end
	print("Part 2 " .. name .. " " .. count)
end

part1("2025/01/example.txt")
part1("2025/01/input.txt")
part2("2025/01/example.txt")
part2("2025/01/input.txt")
