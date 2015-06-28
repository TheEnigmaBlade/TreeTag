function IsTable(thing)
	return thing ~= nil and type(thing) == "table"
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
