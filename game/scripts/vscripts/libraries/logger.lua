function InitLogger(thing, name, indentUnit)
	if thing._DEBUG == nil then
		EnableLogger(thing)
	end
	
	if name == nil then
		name = "LOG"
	elseif type(name) ~= "string" then
		name = tostring(name)
	end
	
	if indentUnit == nil then
		indentUnit = "    "
	end
	
	function thing:Print(text, indent)
		if IsLoggerEnabled(thing) then
			local sIndent = ""
			if indent ~= nil then
				for i = 1, indent do
					sIndent = sIndent .. indentUnit
				end
			end
			print(sIndent .. text)
		end
	end

	function thing:PrintH(text)
		if IsLoggerEnabled(thing) then
			print("[" .. name .. "] " .. text)
		end
	end

	function thing:PrintSep()
		if IsLoggerEnabled(thing) then
			print("------------------------------")
		end
	end

	function thing:PrintTable(table)
		if IsLoggerEnabled(thing) then
			print("---------- Table ----------")
			PrintTable(table)
			print("---------------------------")
		end
	end
end

function EnableLogger(thing)
	thing._DEBUG = true
end

function DisableLogger(thing)
	thing._DEBUG = false
end

function IsLoggerEnabled(thing)
	return thing._DEBUG ~= nil and thing._DEBUG
end
