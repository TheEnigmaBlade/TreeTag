function Build(keys)
	-- Returns the new building (unit) or 'nil' if it couldn't be built
	local building = BuildingBuddy:BuildBuilding(keys)
	if building ~= nil then
		if type(building) == "string" then
			local player = keys.caster:GetPlayerOwner()
			ErrorMessage(building, player)
			return
		end
		
		-- Done callback
		keys:OnConstructionCompleted(function(building)
			BuildingBuddy:PrintH("Completed construction of " .. building:GetUnitName())
			
			building.passivesEnabled = true
			CreateLifeParticles(building)
		end)
		
		-- Building started
		BuildingBuddy:PrintH("Started construction of " .. building:GetUnitName())
		building.passivesEnabled = false
		
		-- Remove invulnerability (I hope)
		--building:SetInvulnCount(0)
		
		-- Make sure the spawner isn't inside the building
		-- Has the possibility of physics glitch exploits, but good enough for now
		FindClearSpaceForUnit(keys.caster, keys.caster:GetAbsOrigin(), true)
	end
end

function UpgradeBuilding(keys)
	local building = keys.caster
	local ability = keys.ability
	local player = building:GetPlayerOwner()
	local result = _UpgradeBuilding(building, ability, player)
	if result ~= nil then
		ErrorMessage(result, player)
	end
end

function _UpgradeBuilding(building, ability, player)
	local abilityName = ability	:GetName()
	BB:PrintH("Upgrading ability '" .. abilityName .. "'")
	
	-- Check if the building is built
	if not building.passivesEnabled then
	BB:Print("Building not complete", 1)
		return "Building Not Complete"
	end
	
	-- Check costs
	local upgradeInfo = KV_Wrap(BuildingBuddy.abilities[abilityName])
	if upgradeInfo ~= nil then
		local playerId = player:GetPlayerID()
		
		local playerGold = PlayerResource:GetGold(playerId)
		local goldCost = upgradeInfo:GetValue("GoldCost", "number", 0)
		if goldCost > playerGold then
		BB:Print("Not enough gold", 1)
			return "Not Enough Gold"
		end
		
		local playerWood = GetPlayerWood(playerId)
		local woodCost = upgradeInfo:GetValue("WoodCost", "number", 0)
		if woodCost > playerWood then
			BB:Print("Not enough wood", 1)
			return "Not Enough Wood"
		end
		
		PlayerResource:ModifyGold(playerId, -goldCost, false, DOTA_ModifyGold_AbilityCost)
		ChangePlayerWood(player, -woodCost)
	end
	
	-- Start building
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
	
	-- Check for a unit swap
	local replaceUnit = upgradeInfo["ReplaceUnit"]
	if replaceUnit ~= nil then
		_ReplaceUnit(building, replaceUnit)
		return
	end
	
	-- Upgrade stuff if possible
	_UpgradeBuildingInfo(building, unitInfo)
	
	-- Swap abilities if required
	local noRemove = upgradeInfo["NoRemove"]
	if noRemove == nil or noRemove == false then
		local index = ability:GetAbilityIndex()
		building:RemoveAbility(ability:GetName())
		
		local nextAbility = upgradeInfo["NextUpgrade"]
		BB:Print("Next upgrade ability: " .. tostring(nextAbility), 1)
		if nextAbility ~= nil then
			building:AddAbility(nextAbility)
			local newAbility = building:GetAbilityByIndex(index)
			newAbility:UpgradeAbility(true)
		else
			building:AddAbility("barebones_empty1")
		end
		
		-- Add ability if required
		local newAbilityName = upgradeInfo["AddAbility"]
		if newAbilityName ~= nil then
			BB:Print("Adding ability: " .. tostring(newAbilityName), 1)
			building:AddAbility(newAbilityName)
		end
	end
end

function _UpgradeBuildingInfo(building, unitInfo)
	local lvlStr = tostring(building.upgradeLevel)
	
	-- Model
	local newModel = unitInfo:GetValue("Model" .. lvlStr, "string")
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
	if newHealth ~= nil then
		building:SetHealth(newHealth)
	end
	
	-- Attack damage
	local damageMin = unitInfo:GetValue("AttackDamageMin" .. lvlStr, "number", nil)
	BB:Print("AttackDamageMin: " .. tostring(damageMin), 2)
	if damageMin ~= nil then
		building:SetBaseDamageMin(damageMin)
	end
	
	local damageMax = unitInfo:GetValue("AttackDamageMax" .. lvlStr, "number", nil)
	BB:Print("AttackDamageMax: " .. tostring(damageMax), 2)
	if damageMax ~= nil then
		building:SetBaseDamageMax(damageMax)
	end
	
	-- Attack rate
	local attackRate = unitInfo:GetValue("AttackRate" .. lvlStr, "float", nil)
	BB:Print("AttackRate: " .. tostring(attackRate), 2)
	if attackRate ~= nil then
		building:SetBaseAttackTime(attackRate)
	end
end

function _ReplaceUnit(unit, newUnitName)
	local owner = unit:GetOwner()
	local location = unit:GetOrigin()
	local playerId = owner:GetPlayerID()
	local playerTeam = PlayerResource:GetTeam(playerId)
	
	local upgradeLevel = unit.upgradeLevel
	
	-- Remove old unit
	unit:Destroy()
	
	-- Create new unit
	unit = CreateUnitByName(newUnitName, location, false, owner, nil, playerTeam)
	if unit == nil then
		return
	end
	--unit:SetInvulnCount(0)
	unit:SetControllableByPlayer(playerId, true)
	unit:SetOwner(owner)
	LevelUpAllAbilities(unit)
	
	unit.upgradeLevel = upgradeLevel
end
