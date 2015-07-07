require("libraries.logger")
require("libraries.table_util")
require("libraries.keyvalue_util")

UnitBuddy = {}
InitLogger(UnitBuddy, "UNITS")
UB = UnitBuddy

function UnitBuddy:Init()
	UB:PrintH("Initializing Unit Buddy")
	UnitBuddy.units = UnitBuddy:_CreateUnitTable()
end

-- Creates a table of special unit information
function UnitBuddy:_CreateUnitTable()
	UB:PrintH("Creating unit table")
	
	units = LoadKeyValues("scripts/npc/npc_units_custom.txt")
	heroes = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
	units = ExtendTable(units, heroes)
	
	unitTable = {}
	for name, unit in pairs(units) do
		if IsTable(unit) then
			local heroOverride = unit["override_hero"]
			if heroOverride ~= nil then
				name = heroOverride
			end
			
			local hullRadius = unit["HullRadius"]
			if hullRadius ~= nil then
				hullRadius = tonumber(hullRadius)
			end
			
			local modelScale = unit["ModelScale"]
			if modelScale ~= nil then
				modelScale = tonumber(modelScale)
			end
			
			unitTable[tostring(name)] = {HullRadius=hullRadius, ModelScale=modelScale, IsBuilding=unit["IsBuilding"]}
		end
	end
	
	UB:PrintTable(unitTable)
	return unitTable
end

function UnitBuddy:InitUnit(unit)
	if UnitBuddy.units == nil then
		UnitBuddy:Init()
	end
	
	if unit == nil then return end
	
	UB:PrintH("Init unit")
	local unitName = unit:GetUnitName()
	UB:Print("Name: " .. unitName, 1)
	local unitData = UnitBuddy.units[unitName]
	UB:Print("Data: " .. tostring(unitData), 1)
	if unitData == nil then return end
	
	local hullRadius = unitData["HullRadius"]
	UB:Print("HullRadius: " .. tostring(hullRadius), 2)
	if hullRadius ~= nil then
		unit:SetHullRadius(hullRadius)
	end
	
	local modelScale = unitData["ModelScale"]
	UB:Print("ModelScale: " .. tostring(modelScale), 2)
	if modelScale ~= nil then
		unit:SetModelScale(modelScale)
	end
end

function UnitBuddy:IsBuilding(unit)
	if UnitBuddy.units == nil then
		UnitBuddy:Init()
	end
	
	if unit == nil then return end
	
	local unitName = unit:GetUnitName()
	local unitData = UnitBuddy.units[unitName]
	if unitData == nil then return end
	
	return unitData["IsBuilding"]
end
