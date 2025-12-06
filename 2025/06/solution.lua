local function part1(name)
	local count = 0
	local rows = {}
	for line in io.lines(name) do
		local cols = {}
		table.insert(rows, cols)
		for val in string.gmatch(line, "([^%s]+)") do
			table.insert(cols, tonumber(val) or val)
		end
	end

	local width = #rows[1]
	local height = #rows
	for x = 1, width do
		local op = rows[height][x]
		local val = op == "*" and 1 or 0
		for y = 1, height - 1 do
			if op == "*" then
				val = val * rows[y][x]
			else
				val = val + rows[y][x]
			end
		end
		count = count + val
	end
	print("Part 1 " .. name .. " " .. count)
end

local function part2(name)
	local count = 0
	local current = 0
	local input = io.open(name):read("*a")
	local width = string.find(input, "\n")
	local height = math.ceil(#input / width)
	local op = ""
	for x = 1, width do
		local chars = {}
		for y = 1, height - 1 do
			local pos = x + (y - 1) * width
			table.insert(chars, string.sub(input, pos, pos))
		end
		local oppos = x + (height - 1) * width
		local opchar = string.sub(input, oppos, oppos)
		if opchar == "*" then
			op = opchar
			current = 1
		elseif opchar == "+" then
			op = opchar
			current = 0
		end
		local num = tonumber(table.concat(chars))
		if num then
			if op == "*" then
				current = current * num
			else
				current = current + num
			end
		else
			count = count + current
		end
	end
	print("Part 2 " .. name .. " " .. count)
end

part1("2025/06/example.txt")
part1("2025/06/input.txt")
part2("2025/06/example.txt")
part2("2025/06/input.txt")
