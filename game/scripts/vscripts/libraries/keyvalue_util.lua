function KV_Wrap(table)
	if table == nil then
		return nil
	end
	
	function table:GetValue(key, expectedType, defaultValue)
		return KV_GetValue(table, key, expectedType, defaultValue)
	end
	
	function table:GetMultiValue(key, expectedType)
		return KV_GetMultiValue(table, key, expectedType)
	end
	
	function table:HasValue(key)
		return KV_HasValue(table, key)
	end
	
	return table
end

function KV_GetValue(table, key, expectedType, defaultValue)
	local val = table[key]
	return _parseval(val, expectedType, defaultValue)
end

function KV_GetMultiValue(table, key, expectedType)
	local val = KV_GetValue(table, key, "string", nil)
	if val == nil then
		return nil
	end
	
	local vals = _splitstring(val)
	local valTable = {}
	for i, s in ipairs(vals) do
		local v = _parseval(s, expectedType, nil)
		if v ~= nil then
			valTable[i] = v
		end
	end
	
	return valTable
end

function KV_HasValue(table, key)
	local val = table[key]
	return val ~= nil and val ~= ""
end

function _parseval(val, expectedType, defaultValue)
	if val == nil or tostring(val) == "" then
		return defaultValue
	end

	if expectedType == "bool" then
		if tostring(val) == "1" then
			return true
		end
		return false
	elseif expectedType == "number" or expectedType == "float" then
		return tonumber(val)
	end
	return tostring(val)
end

function _splitstring(str, sep)
	if sep == nil then sep = "%s" end
	local t={} ; i=1
	for s in string.gmatch(str, "([^"..sep.."]+)") do
		t[i] = s
		i = i + 1
	end
	return t
end
