local function part1(name, connections)
	local boxes = {}
	local circuits = {}
	for line in io.lines(name) do
		local x, y, z = string.match(line, "(%d+),(%d+),(%d+)")
		local circuit = {}
		local box = { x = tonumber(x), y = tonumber(y), z = tonumber(z), circuit = circuit }
		table.insert(circuit, box)
		table.insert(circuits, circuit)
		table.insert(boxes, box)
	end
	local distances = {}
	for ai = 1, #boxes - 1 do
		local a = boxes[ai]
		for bi = ai + 1, #boxes do
			local b = boxes[bi]
			local distance = math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2 + (a.z - b.z) ^ 2)
			table.insert(distances, { distance = distance, a = a, b = b })
		end
	end
	table.sort(distances, function(a, b)
		return a.distance < b.distance
	end)
	for i = 1, connections do
		local a = distances[i].a
		local b = distances[i].b
		if a.circuit ~= b.circuit then
			local ac = a.circuit
			local bc = b.circuit
			for k, box in pairs(bc) do
				table.insert(ac, box)
				box.circuit = ac
				bc[k] = nil
			end
		end
	end
	table.sort(circuits, function(a, b)
		return #a > #b
	end)
	local count = #circuits[1] * #circuits[2] * #circuits[3]
	print("Part 1 " .. name .. " " .. count)
end

local function part2(name)
	local count = 0
	local boxes = {}
	local circuits = {}
	for line in io.lines(name) do
		local x, y, z = string.match(line, "(%d+),(%d+),(%d+)")
		local circuit = {}
		local box = { x = tonumber(x), y = tonumber(y), z = tonumber(z), circuit = circuit }
		table.insert(circuit, box)
		table.insert(circuits, circuit)
		table.insert(boxes, box)
	end
	local distances = {}
	for ai = 1, #boxes - 1 do
		local a = boxes[ai]
		for bi = ai + 1, #boxes do
			local b = boxes[bi]
			local distance = math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2 + (a.z - b.z) ^ 2)
			table.insert(distances, { distance = distance, a = a, b = b })
		end
	end
	table.sort(distances, function(a, b)
		return a.distance < b.distance
	end)
	for _, d in ipairs(distances) do
		local a = d.a
		local b = d.b
		if a.circuit ~= b.circuit then
			local ac = a.circuit
			local bc = b.circuit
			if #ac + #bc == #boxes then
				count = a.x * b.x
				break
			end
			for k, box in pairs(bc) do
				table.insert(ac, box)
				box.circuit = ac
				bc[k] = nil
			end
		end
	end
	print("Part 2 " .. name .. " " .. count)
end

part1("2025/08/example.txt", 10)
part1("2025/08/input.txt", 1000)
part2("2025/08/example.txt")
part2("2025/08/input.txt")
