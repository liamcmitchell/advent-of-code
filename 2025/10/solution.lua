-- Switched to LuaJIT
local bit = require("bit")

local function part1(name)
	local start = os.clock()
	local result = 0
	for line in io.lines(name) do
		local i = 0
		local target = 0
		for char in string.gmatch(line, "[.#]") do
			if char == "#" then
				target = bit.bor(target, bit.lshift(1, i))
			end
			i = i + 1
		end
		local buttons = {}
		for group in string.gmatch(line, "%(.-%)") do
			local button = 0
			for num in string.gmatch(group, "%d+") do
				button = bit.bor(button, bit.lshift(1, tonumber(num) or 0))
			end
			buttons[#buttons + 1] = button
		end
		local found = { [0] = true }
		local todo = { 0 }
		local done = 0
		local presses = 0
		while not found[target] do
			presses = presses + 1
			for j = 1 + done, #todo do
				local state = todo[j]
				for _, button in ipairs(buttons) do
					local next = bit.bxor(state, button)
					if next == target then
						result = result + presses
						goto continue
					elseif not found[next] then
						found[next] = presses
						todo[#todo + 1] = next
					end
				end
			end
		end
		::continue::
	end
	print("Part 1 " .. name .. " " .. result .. " in " .. string.format("%.3f", os.clock() - start))
end

local function part2(name)
	local start = os.clock()
	local result = 0
	for line in io.lines(name) do
		local counters = {}
		local countersum = 0
		for num in string.gmatch(string.match(line, "%{.+%}"), "%d+") do
			local target = tonumber(num)
			table.insert(counters, { i = #counters, target = target, buttons = {} })
			countersum = countersum + target
		end
		local buttons = {}
		for group in string.gmatch(line, "%(.-%)") do
			local button = { i = #buttons, min = 0, max = 9999, counters = {}, saves = {} }
			for num in string.gmatch(group, "%d+") do
				local counter = counters[(tonumber(num) or 0) + 1]
				button.max = math.min(button.max, counter.target)
				table.insert(button.counters, counter)
				table.insert(counter.buttons, button)
			end
			table.insert(buttons, button)
		end
		local function save()
			for _, button in ipairs(buttons) do
				table.insert(button.saves, { button.min, button.max })
			end
		end
		local function restore()
			for _, button in ipairs(buttons) do
				local saved = table.remove(button.saves)
				button.min = saved[1]
				button.max = saved[2]
			end
		end
		local function permutations(counter)
			local p = 1
			for _, button in ipairs(counter.buttons) do
				p = p * (1 + button.max - button.min)
			end
			return p
		end
		local function constrain()
			local changed = true
			while changed do
				changed = false
				for _, counter in ipairs(counters) do
					local totalmin = 0
					local totalmax = 0
					for _, button in ipairs(counter.buttons) do
						totalmin = totalmin + button.min
						totalmax = totalmax + button.max
					end
					for _, button in ipairs(counter.buttons) do
						local othermin = totalmin - button.min
						local newmax = counter.target - othermin
						if newmax < button.min then
							return false
						end
						if newmax < button.max then
							button.max = newmax
							changed = true
						end
						local othermax = totalmax - button.max
						local newmin = counter.target - othermax
						if newmin > button.max then
							return false
						end
						if newmin > button.min then
							button.min = newmin
							changed = true
						end
					end
				end
			end
			return true
		end
		local function nexteasiest()
			local lowesti = nil
			local lowestp = nil
			for i, counter in ipairs(counters) do
				local p = permutations(counter)
				if (not lowestp or p < lowestp) and p ~= 1 then
					lowestp = p
					lowesti = i
				end
			end
			return lowesti
		end
		local function check()
			for _, counter in ipairs(counters) do
				local sum = 0
				for _, button in ipairs(counter.buttons) do
					sum = sum + button.min
				end
				if sum ~= counter.target then
					return nil
				end
			end
			local presses = 0
			for _, button in ipairs(buttons) do
				presses = presses + button.min
			end
			return presses
		end
		local function search(c, b)
			if not c then
				return check()
			end
			local counter = counters[c]
			local button = counter.buttons[b]
			if not button then
				return search(nexteasiest(), 1)
			end
			if button.min == button.max then
				return search(c, b + 1)
			end
			local lowest = nil
			for n = button.max, button.min, -1 do
				save()
				button.min = n
				button.max = n
				if constrain() then
					local presses = search(c, b + 1)
					if presses and (not lowest or presses < lowest) then
						lowest = presses
					end
				end
				restore()
			end
			return lowest
		end
		constrain()
		result = result + search(nexteasiest(), 1)
	end
	print("Part 2 " .. name .. " " .. result .. " in " .. string.format("%.3f", os.clock() - start))
end

part1("2025/10/example.txt")
part1("2025/10/input.txt")
part2("2025/10/example.txt")
part2("2025/10/input.txt")
