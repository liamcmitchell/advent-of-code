local function part1(name)
	local tiles = {}
	for line in io.lines(name) do
		local x, y = string.match(line, "(%d+),(%d+)")
		table.insert(tiles, { tonumber(x), tonumber(y) })
	end
	local count = 0
	for i = 1, #tiles - 1 do
		for j = i + 1, #tiles do
			local x = 1 + math.abs(tiles[i][1] - tiles[j][1])
			local y = 1 + math.abs(tiles[i][2] - tiles[j][2])
			count = math.max(count, x * y)
		end
	end
	print("Part 1 " .. name .. " " .. count)
end

local smallest = function(a, b)
	return a[1] < b[1]
end

local checkstart = function(lines, min)
	local l = 1
	local r = #lines
	local m = 0
	while l < r do
		m = l + math.floor((r - l) / 2)
		if lines[m][1] < min then
			l = m + 1
		else
			r = m
		end
	end
	return l
end

local function part2(name)
	local start = os.clock()
	local tiles = {}
	for line in io.lines(name) do
		local x, y = string.match(line, "(%d+),(%d+)")
		table.insert(tiles, { tonumber(x), tonumber(y) })
	end
	-- prepare tables of sorted horizontal and vertical lines
	local horizontal = {}
	local vertical = {}
	for i, tile in ipairs(tiles) do
		local nexttile = tiles[i % #tiles + 1]
		local minx = math.min(tile[1], nexttile[1])
		local maxx = math.max(tile[1], nexttile[1])
		local miny = math.min(tile[2], nexttile[2])
		local maxy = math.max(tile[2], nexttile[2])
		if minx == maxx then
			table.insert(vertical, { minx, miny, maxy })
		else
			table.insert(horizontal, { miny, minx, maxx })
		end
	end
	table.sort(horizontal, smallest)
	table.sort(vertical, smallest)
	local count = 0
	for i = 1, #tiles - 1 do
		local ix = tiles[i][1]
		local iy = tiles[i][2]
		for j = i + 1, #tiles do
			local jx = tiles[j][1]
			local jy = tiles[j][2]
			local minx = math.min(ix, jx)
			local maxx = math.max(ix, jx)
			local miny = math.min(iy, jy)
			local maxy = math.max(iy, jy)
			local area = (1 + maxx - minx) * (1 + maxy - miny)
			if area > count then
				-- Check for lines through area.
				for h = checkstart(horizontal, miny), #horizontal do
					local line = horizontal[h]
					if line[1] > miny and line[1] < maxy and not (line[2] >= maxx or line[3] <= minx) then
						goto continue
					elseif line[1] > maxy then
						break
					end
				end
				for v = checkstart(vertical, minx), #vertical do
					local line = vertical[v]
					if line[1] > minx and line[1] < maxx and not (line[2] >= maxy or line[3] <= miny) then
						goto continue
					elseif line[1] > maxx then
						break
					end
				end
				count = area
			end
			::continue::
		end
	end
	print("Part 2 " .. name .. " " .. count .. " in " .. os.clock() - start .. " seconds")
end

part1("2025/09/example.txt")
part1("2025/09/input.txt")
part2("2025/09/example.txt")
part2("2025/09/input.txt")
