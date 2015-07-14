function UpgradeAbility(keys)
	local caster = keys.caster
	local abilityName = keys.AbilityName
	
	local ability = caster:FindAbilityByName(abilityName)
	ability:UpgradeAbility(true)
end

function SpawnWisp(keys)
	GameMode:PrintH("Spawning wisp")
	GameMode:PrintTable(keys)
	
	local caster = keys.caster
	local player = caster:GetPlayerOwner()
	
	if not caster.passivesEnabled then
		ErrorMessage("Building Not Complete", player)
		return
	end
	
	local playerId = caster:GetPlayerOwnerID()
	local playerTeam = caster:GetTeamNumber()
	local playerHero = player:GetAssignedHero()
	local location = caster:GetOrigin()
	GameMode:Print("Player: " .. tostring(playerId), 1)
	GameMode:Print("Team: " .. tostring(playerTeam), 1)
	GameMode:Print("Location: " .. tostring(location), 1)
	
	local unit = CreateUnitByName("npc_wood_gatherer", location, true, playerHero, playerHero, playerTeam)
	if unit == nil then
		return
	end
	unit:SetControllableByPlayer(playerId, true)
end
