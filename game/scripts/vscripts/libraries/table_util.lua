function IsTable(thing)
	return thing ~= nil and type(thing) == "table"
end

function InArray(table, val)
	if table == nil then
		return false
	end
	
	for i, v in ipairs(table) do
		if v == val then
			return true
		end
	end
	return false
end

function ExtendTable(table, table2)
	if table == nil then return table2 end
	if table2 == nil then return table end
	
	for k, v in pairs(table2) do
		table[k] = v
	end
	return table
end

function ShallowCopy(thing)
    if IsTable(thing) then
        local copy = {}
        for k, v in pairs(thing) do
            copy[k] = v
        end
		return copy
	end
    return thing
end

function DeepCopy(thing)
    if IsTable(thing) then
        local copy = {}
        for k, v in pairs(thing) do
            copy[k] = DeepCopy(v)
        end
		return copy
	end
    return thing
end
