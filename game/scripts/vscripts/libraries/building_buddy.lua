require("libraries.logger")
require("libraries.table_util")
require("libraries.keyvalue_util")

BuildingBuddy = {}
InitLogger(BuildingBuddy, "BUILDER")
BB = BuildingBuddy

--------------------
-- Initialization --
--------------------

function BuildingBuddy:Init()
	BB:PrintH("Initializing Building Buddy")
	BuildingBuddy.abilities = _CreateBuildingAbilityTable()
	BuildingBuddy.units = _CreateBuildingUnitTable()
end

-- Creates a table of building information by ability name
function _CreateBuildingAbilityTable()
	BB:PrintH("Creating building ability table")
	abilityTable = {}
	
	local abilities = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
	for name, ability in pairs(abilities) do
		if IsTable(ability) then
			local building = ability["Building"]
			if building ~= nil and IsTable(building) then
				abilityTable[tostring(name)] = building
			end
		end
	end
	
	local items = LoadKeyValues("scripts/npc/npc_items_custom.txt")
	for name, item in pairs(items) do
		if IsTable(item) then
			local building = item["Building"]
			if building ~= nil and IsTable(building) then
				abilityTable[tostring(name)] = building
			end
		end
	end
	
	--BB:PrintTable(abilityTable)
	return abilityTable
end

-- Creates a table of building information by unit name
function _CreateBuildingUnitTable()
	BB:PrintH("Creating building ability table")
	
	units = LoadKeyValues("scripts/npc/npc_units_custom.txt")
	unitTable = {}
	
	for name, unit in pairs(units) do
		if IsTable(unit) then
			local baseClass = unit["BaseClass"]
			if baseClass ~= nil and baseClass == "npc_dota_building" then
				unitTable[tostring(name)] = unit
			end
		end
	end
	
	--BB:PrintTable(unitTable)
	return unitTable
end

-------------------
-- Functionality --
-------------------

function BuildingBuddy:BuildBuilding(keys)
	-- Callbacks
	function keys:OnConstructionCompleted(callback)
		keys.onConstructionCompleted = callback
	end
	
	-- Add building
	BB:PrintH("Adding building")
	
	-- Information from the Datadriven call
	local ability = keys.ability
	local abilityName = ability:GetAbilityName()
	BB:Print("Ability: " .. abilityName, 1)
	local builder = keys.caster
	BB:Print("Builder: " .. tostring(builder), 1)
	local player = builder:GetPlayerOwner()
	local playerId = player:GetPlayerID()
	BB:Print("Player: " .. tostring(player) .. " (" .. tostring(playerId) .. ")", 1)
	local target = keys.target_points[1]
	BB:Print("Target: " .. tostring(target))
	
	-- Building information from ability
	local abilityInfo = KV_Wrap(BuildingBuddy.abilities[abilityName])
	if abilityInfo == nil then
		BB:Print("ERROR: Ability '" .. abilityName .. "' doesn't define a building", 1)
		return
	end
	BB:Print("Building found:", 1)
	BB:PrintTable(abilityInfo)
	
	-- Check required values
	if not abilityInfo:HasValue("UnitName") then
		BB:Print("ERROR: Building '" .. abilityName .. "' doesn't specify 'UnitName'", 1)
		return
	end
	
	-- Building information from unit
	local unitName = abilityInfo:GetValue("UnitName")
	local unitInfo = KV_Wrap(BuildingBuddy.units[unitName])
	if unitInfo == nil then
		BB:Print("WARNING: Not using custom unit", 1)
	end
	
	-- Check ability costs
	local goldCost = GetPriorityValue(abilityInfo, "GoldCost", unitInfo, "GoldCost", "number", 0)
	if goldCost > PlayerResource:GetGold(playerId) then
		return
	end
	
	-- Check build location
	if GridNav:IsBlocked(target) or not GridNav:IsTraversable(target) then
		return
	end
	
	local buildRadius = GetPriorityValue(abilityInfo, "Size", unitInfo, "CollisionSize", "float", 80)
	local closestBuilding = Entities:FindByClassnameNearest("npc_dota_building", target, buildRadius)
	if closestBuilding ~= nil then
		return
	end
	
	-- Create unit and start building
	local unit = _CreateBuildingUnit(abilityInfo, target, player)
	if unit ~= nil then
		-- Remove costs
		PlayerResource:SpendGold(playerId, goldCost, DOTA_ModifyGold_AbilityCost)
		
		-- Start da timers
		local buildTime = GetPriorityValue(abilityInfo, "BuildTime", unitInfo, "BuildTime", "number", 2)
		
		Timers:CreateTimer(buildTime, function()
			keys.onConstructionCompleted(unit)
		end)
		
		_AnimateBuilding(unit, unitInfo, abilityInfo, buildTime)
	end
	return unit
end

function _CreateBuildingUnit(abilityInfo, location, player)
	BB:PrintH("Creating building unit")
	
	local unitName = abilityInfo:GetValue("UnitName", "string")
	local playerHero = player:GetAssignedHero()
	local playerId = player:GetPlayerID()
	local playerTeam = PlayerResource:GetTeam(playerId)
	local playerCanControl = abilityInfo:GetValue(playerId)
	
	local unit = CreateUnitByName(unitName, location, false, playersHero, nil, playerTeam)
	if unit == nil then
		return
	end
	unit:SetControllableByPlayer(playerId, true)
	unit:SetOwner(playerHero)
	unit:SetMana(0)
	
	return unit
end

function _AnimateBuilding(unit, unitInfo, abilityInfo, buildTime)
	BB:PrintH("Animating building unit")
	
	local animateScale = abilityInfo:GetValue("AnimateScale", "bool", true)
	local animateHealth = abilityInfo:GetValue("AnimateHealth", "bool", true)
	
	local updateInterval = 0.03
	local buildRate =  updateInterval / buildTime
	local completeTime = GameRules:GetGameTime() + buildTime
	
	-- Scale growth animation
	BB:Print("Scale: " .. tostring(animateScale), 1)
	if animateScale then
		local scaleEnd = unit:GetModelScale()
		BB:Print("scaleEnd: " .. tostring(scaleEnd), 2)
		local currentScale = scaleEnd * abilityInfo:GetValue("ScaleStart", "float", 0.2)
		BB:Print("currentScale: " .. tostring(currentScale), 2)
		local scaleRate = (scaleEnd - currentScale) * buildRate
		BB:Print("scaleRate: " .. tostring(scaleRate), 2)
		
		unit:SetModelScale(currentScale)
		
		-- Animate!
		unit.buildScaleTimer = DoUniqueString("scale")
		Timers:CreateTimer(unit.buildScaleTimer, {callback = function()
			-- Check if done
			if GameRules:GetGameTime() >= completeTime then
				unit:SetModelScale(scaleEnd)
				return nil
			end
			
			currentScale = currentScale + scaleRate
			if currentScale > scaleEnd then
				currentScale = scaleEnd
			end
			unit:SetModelScale(currentScale)
			
			return updateInterval
		end})
	end
	
	-- Health growth animation
	BB:Print("Health: " .. tostring(animateHealth), 1)
	if animateHealth then
		local healthEnd = unit:GetMaxHealth()
		local currentHealth = 1
		local healthRate = (healthEnd - currentHealth) * buildRate
		
		unit:SetHealth(currentHealth)
		
		-- Animate!
		unit.buildHealthTimer = DoUniqueString("health")
		Timers:CreateTimer(unit.buildHealthTimer, {callback = function()
			-- Check if done
			if GameRules:GetGameTime() >= completeTime then
				unit:SetHealth(healthEnd)
				return nil
			end
			
			currentHealth = currentHealth + healthRate
			if currentHealth > healthEnd then
				currentHealth = healthEnd
			end
			unit:SetHealth(currentHealth)
			
			return updateInterval
		end})
	end
end

---------------
-- Utilities --
---------------

function GetPriorityValue(table, key, backupTable, backupKey, expectedType, defaultValue)
	if table:HasValue(key) then
		local value = table:GetValue(key, expectedType, nil)
		if value ~= nil then
			return value
		end
	end
	
	if backupTable ~= nil then
		return backupTable:GetValue(backupKey, expectedType, defaultValue)
	end
	
	return defaultValue
end
