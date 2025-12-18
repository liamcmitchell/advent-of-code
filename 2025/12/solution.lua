-- 😭 wish I had checked the input sooner.
-- Solving for the input was stupid easy.
-- Solving for the example is much harder and still not done.
-- Leaving the WIP and calling it a day 😮‍💨.
-- 🎄

local function part1(name)
	local start = os.clock()
	local result = 0
	local shapes = {}
	local shapesize = {}
	local regions = {}
	for line in io.lines(name) do
		if string.match(line, "^%d:") then
			table.insert(shapes, {})
		elseif string.find(line, "x") then
			table.insert(regions, {})
			for num in string.gmatch(line, "%d+") do
				table.insert(regions[#regions], tonumber(num))
			end
		else
			for val in string.gmatch(line, "[#.]") do
				table.insert(shapes[#shapes], val == "#")
				if val == "#" then
					shapesize[#shapes] = (shapesize[#shapes] or 0) + 1
				end
			end
		end
	end
	local function rotate(shape)
		local tl, tc, tr, ml, mc, mr, bl, bc, br = unpack(shape)
		return { tr, mr, br, tc, mc, bc, tl, ml, bl }
	end
	local function mirror(shape)
		local tl, tc, tr, ml, mc, mr, bl, bc, br = unpack(shape)
		return { tr, tc, tl, mr, mc, ml, br, bc, bl }
	end
	local function equal(a, b)
		if a == b then
			return true
		end
		if type(a) == "table" and type(b) == "table" and #a == #b then
			for key, value in pairs(a) do
				if not equal(value, b[key]) then
					return false
				end
			end
			return true
		end
		return false
	end
	local function sum(table)
		local res = 0
		for _, value in pairs(table) do
			res = res + value
		end
		return res
	end
	-- for each shape, calc starts and heights from each side
	-- produce a list of unique faces optimized for packing loop
	local faces = {}
	for s, shape in ipairs(shapes) do
		for _ = 1, 2 do
			shape = mirror(shape)
			for _ = 1, 4 do
				shape = rotate(shape)
				local starts = {}
				local heights = {}
				local hollow = false
				for y = 0, 2 do
					local height = 0
					local started = false
					local finished = false
					for x = 0, 2 do
						local i = 1 + y * 3 + x
						local filled = shape[i]
						if filled then
							if finished then
								hollow = true
							elseif not started then
								started = true
								table.insert(starts, x)
							end
							height = x + 1
						else
							if started then
								finished = true
							end
						end
					end
					table.insert(heights, height)
				end
				if not hollow then
					local face = { shapei = s, shape = shape, starts = starts, heights = heights }
					local duplicate = false
					for _, value in ipairs(faces) do
						if equal(value, face) then
							duplicate = true
						end
					end
					if not duplicate then
						table.insert(faces, face)
					end
				end
			end
		end
	end
	local function calcfit(face, heights, x)
		local fa, fb, fc = unpack(face.starts)
		local ha, hb, hc = unpack(heights, x, x + 2)
		local min = math.max(ha - fa, hb - fb, hc - fc)
		local gaps = fa - ha + min + fb - hb + min + fc - hc + min
		return min, gaps
	end
	local function mingaps(shapecounts, heights, x)
		local res = nil
		for _, face in ipairs(faces) do
			if shapecounts[face.shapei] > 0 then
				local min = calcfit(face, heights, x)
				if min == 0 then
					return 0
				elseif not res or min < res then
					res = min
				end
			end
		end
		return res
	end
	local function mingapsrange(shapecounts, heights, x1, x2)
		local mins = {}
		for i = x1, x2 + 2 do
			mins[i] = 99
		end
		for x = x1, x2 do
			local min = mingaps(shapecounts, heights, x)
			mins[x] = math.min(min, mins[x])
			mins[x + 1] = math.min(min, mins[x + 1])
			mins[x + 2] = math.min(min, mins[x + 2])
		end
		local res = math.min(unpack(mins, x1, x2 + 2))
		return res
	end

	-- solving
	for _, region in ipairs(regions) do
		local width, height = unpack(region)
		local shapecounts = { unpack(region, 3) }
		if math.floor(width / 3) * math.floor(height / 3) >= sum(shapecounts) then
			-- shapes fit without packing (half of input)
			result = result + 1
			goto nextregion
		end
		local minsize = 0
		for i, s in ipairs(shapesize) do
			minsize = minsize + s * shapecounts[i]
		end
		if minsize > width * height then
			-- impossible (other half of input)
			goto nextregion
		end
		-- what follows is my attempt at a filling the available space
		-- tetris style, choosing shapes by minimizing gaps
		local heights = {}
		for i = 1, width do
			heights[i] = 0
		end
		while math.max(unpack(shapecounts)) > 0 do
			local totalcounts = sum(shapecounts)
			local bestindex = 0
			local bestx = 0
			local bestgaps = 99
			-- left to right
			for x = 1, width - 2 do
				-- look for best match
				for index, face in ipairs(faces) do
					local remaining = shapecounts[face.shapei]
					if remaining == 0 then
						goto nextface
					end
					local min, gaps = calcfit(face, heights, x)
					if min + 3 > height or gaps > bestgaps then
						goto nextface
					end
					-- if we place, will this cause more gaps?
					local newheights = { unpack(heights) }
					for i = 0, 2 do
						newheights[x + i] = min + face.heights[i + 1]
					end
					gaps = gaps + mingapsrange(shapecounts, newheights, math.max(1, x - 3), math.min(width - 2, x + 3))
					gaps = gaps + (-remaining / totalcounts)
					if gaps < bestgaps then
						bestgaps = gaps
						bestindex = index
						bestx = x
					end
					::nextface::
				end
			end

			if bestindex == 0 then
				-- no shape found
				-- to be really sure we would have to exhoustively check all combinations
				-- not even attempted
				goto nextregion
			else
				local face = faces[bestindex]
				local remaining = shapecounts[face.shapei]
				shapecounts[face.shapei] = remaining - 1
				local sa, sb, sc = unpack(face.starts)
				local a, b, c = unpack(heights, bestx, bestx + 2)
				local min = math.max(a - sa, b - sb, c - sc)
				heights[bestx] = min + face.heights[1]
				heights[bestx + 1] = min + face.heights[2]
				heights[bestx + 2] = min + face.heights[3]
				-- debug to render current heights and inserted shape at each step
				if false then
					for y = 1, math.max(unpack(heights)) do
						local line = {}
						for x = 1, width do
							if heights[x] >= y then
								if x >= bestx and x <= bestx + 2 and y > min then
									table.insert(line, "0")
								else
									table.insert(line, "#")
								end
							else
								table.insert(line, ".")
							end
						end
						print(table.concat(line))
					end
				end
			end
		end
		result = result + 1
		::nextregion::
	end
	print("Part 1 " .. name .. " " .. result .. " in " .. string.format("%.3f", os.clock() - start))
end

part1("2025/12/example.txt")
part1("2025/12/input.txt")
