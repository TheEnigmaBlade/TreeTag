function Build(keys)
	-- Returns the new building (unit) or 'nil' if it couldn't be built
	local building = BuildingBuddy:BuildBuilding(keys)
	if building ~= nil then
		-- Done callback
		keys:OnConstructionCompleted(function(building)
			BuildingBuddy:PrintH("Completed construction of " .. building:GetUnitName())
			
			building.passivesEnabled = true
		end)
		
		-- Building started
		BuildingBuddy:PrintH("Started construction of " .. building:GetUnitName())
		building.passivesEnabled = false
		
		FindClearSpaceForUnit(keys.caster, keys.caster:GetAbsOrigin(), true)
	end
end

function UpgradeBuilding(keys)
	local currentAbility = keys.ability
	BB:PrintH("Upgrading ability '" .. currentAbility:GetName() .. "'")
	
	local building = keys.caster
	local buildingName = building:GetUnitName()
	BB:Print("On building: " .. buildingName, 1)
	
	-- Get unit containing upgrade information
	local unitInfo = KV_Wrap(BuildingBuddy.units[buildingName])
	if unitInfo == nil then
		BB:Print("WARNING: '" .. buildingName .. "' is not a custom unit, no special upgrades", 1)
		return
	end
	
	-- Increment upgrade level
	if building.upgradeLevel == nil then
		building.upgradeLevel = 1
	else
		building.upgradeLevel = building.upgradeLevel + 1
	end
	BB:Print("Upgrade level: " .. tostring(building.upgradeLevel), 1)
	
	-- Upgrade stuff if possible
	_UpgradeBuildingInfo(building, unitInfo)
	
	-- Swap abilities if required
	local noRemove = keys.NoRemove
	if noRemove == nil or noRemove == false then
		local index = currentAbility:GetAbilityIndex()
		building:RemoveAbility(currentAbility:GetName())
		
		local nextAbility = keys.NextUpgrade
		BB:Print("Next upgrade ability: " .. tostring(nextAbility), 1)
		if nextAbility ~= nil then
			building:AddAbility(nextAbility)
			local newAbility = building:GetAbilityByIndex(index)
			newAbility:UpgradeAbility(true)
		else
			building:AddAbility("barebones_empty1")
		end
	end
end

function _UpgradeBuildingInfo(building, unitInfo)
	local lvlStr = tostring(building.upgradeLevel)
	
	-- Model
	local newModel = unitInfo:GetMultiValue("Model" .. lvlStr, "string")
	BB:Print("Model: " .. tostring(newModel), 2)
	if newModel ~= nil then
		building:SetModel(newModel)
	end
	
	-- Model scale
	BB:Print("Upgrading stuff", 1)
	local newScale = unitInfo:GetValue("ModelScale" .. lvlStr, "float", nil)
	BB:Print("Scale: " .. tostring(newScale), 2)
	if newScale ~= nil then
		building:SetModelScale(newScale)
	end
	
	-- Render color
	local newColor = unitInfo:GetMultiValue("RenderColor" .. lvlStr, "number")
	BB:Print("Color: ", 2)
	BB:PrintTable(newColor)
	if newColor ~= nil then
		building:SetRenderColor(newColor[1], newColor[2], newColor[3])
	end
	
	-- Health
	local newHealth = unitInfo:GetValue("StatusHealth" .. lvlStr, "number", nil)
	BB:Print("Health: " .. tostring(newHealth), 2)
	if value ~= nil then
		building:SetHealth(newHealth)
	end
end
