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

local function part2(name)
	local start = os.clock()
	local tiles = {}
	for line in io.lines(name) do
		local x, y = string.match(line, "(%d+),(%d+)")
		table.insert(tiles, { tonumber(x), tonumber(y) })
	end
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
				local whole = true
				-- Check for lines through area.
				for k, tile in ipairs(tiles) do
					local kx = tile[1]
					local ky = tile[2]
					if kx > minx and kx < maxx then
						local nexttile = tiles[k % #tiles + 1]
						local kminy = math.min(tile[2], nexttile[2])
						local kmaxy = math.max(tile[2], nexttile[2])
						if not (kminy >= maxy or kmaxy <= miny) then
							whole = false
							break
						end
					end
					if ky > miny and ky < maxy then
						local nexttile = tiles[k % #tiles + 1]
						local kminx = math.min(tile[1], nexttile[1])
						local kmaxx = math.max(tile[1], nexttile[1])
						if not (kminx >= maxx or kmaxx <= minx) then
							whole = false
							break
						end
					end
				end
				if whole == true then
					count = area
				end
			end
		end
	end
	print("Part 2 " .. name .. " " .. count .. " in " .. os.clock() - start .. " seconds")
end

part1("2025/09/example.txt")
part1("2025/09/input.txt")
part2("2025/09/example.txt")
part2("2025/09/input.txt")
