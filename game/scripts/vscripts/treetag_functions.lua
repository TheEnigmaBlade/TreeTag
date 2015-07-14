function InitDummyHero(hero)
	hero:SetAbilityPoints(0)
	
	local modifiers = CreateItem("item_modifier_master", nil, nil)
	modifiers:ApplyDataDrivenModifier(hero, hero, "is_dummy_hero", {})
end

function InitGoodHero(hero)
	hero:SetAbilityPoints(START_LVLS_GOOD)
	
	LevelUpAllAbilities(hero)
	
	for i, itemName in ipairs(GOOD_GUY_ITEMS) do
		local item = CreateItem(itemName, hero, hero)
		hero:AddItem(item)
	end
end

function InitBadHero(hero)
	hero:SetAbilityPoints(START_LVLS_BAD)
	
	--local ability = hero:GetAbilityByIndex(0)
	--ability:UpgradeAbility(true)
end

function GetPlayerWood(playerId)
	return GameMode.playerWood[playerId]
end

function ChangePlayerWood(player, value)
	local playerId = player:GetPlayerID()
	GameMode.playerWood[playerId] = GameMode.playerWood[playerId] + value
	CustomGameEventManager:Send_ServerToPlayer(player, "player_has_wood", {wood=GameMode.playerWood[playerId]})
end

-- Called by the 'reset_dummy_pos' map entity entered by dummy hero
function ReturnDummyToCenter(keys)
	local entity = keys.activator
	if entity ~= nil then
		local unitName = entity:GetUnitName()
		
		-- It's a dummy unit! They shouldn't be leaving!
		if unitName == HERO_DUMMY then
			GameMode:PrintH("Uh oh! A dummy hero is trying to leave the center!")
			
			local player = entity:GetOwner()
			local playerId = player:GetPlayerID()
			GameMode:Print("Player: " .. tostring(playerId), 1)
			
			entity:SetOrigin(Vector(0, 0, 0))
			FindClearSpaceForUnit(entity, entity:GetOrigin(), true)
		end
	end
end

function CreateLifeParticles(unit)
	local unitName = unit:GetUnitName()
	if unitName == "npc_building_gold_gen" then
		local goldPart = ParticleManager:CreateParticle("particles/buildings/cpy_rune_bountygold.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
		local goldPartPos = unit:GetAbsOrigin() + Vector(0, 0, 20)
		ParticleManager:SetParticleControl(goldPart, 0, goldPartPos)
	elseif unitName == "npc_wood_gatherer" then
		ParticleManager:CreateParticle("particles/units/wisp/cpy_wisp_ambient.vpcf", PATTACH_OVERHEAD_FOLLOW, unit)
	end
end

function CreateDeathParticles(unit)
	local unitName = unit:GetUnitName()
	local shrink = true
	
	if unitName == "npc_building_gold_gen" then
		ParticleManager:CreateParticle("particles/econ/items/effigies/status_fx_effigies/base_statue_destruction_gold.vpcf", PATTACH_ABSORIGIN, unit)
	elseif unitName == "npc_building_basic_tower" then
		ParticleManager:CreateParticle("particles/radiant_fx/tower_good3_destroy_lvl3_fallback_med.vpcf", PATTACH_ABSORIGIN, unit)
	elseif unitName == "npc_building_wall" or unitName == "npc_building_invisible_wall"  or unitName == "npc_building_scout_tower" then
		ParticleManager:CreateParticle("particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_base_attack_explosion.vpcf", PATTACH_ABSORIGIN, unit)
	end
	
	if shrink then
		local scale = 1.0
		Timers:CreateTimer(function()
			scale = scale - 0.2
			unit:SetModelScale(scale)
			if scale > 0 and not unit:IsNull() then
				return 0.03
			end
		end)
	else
		unit:SetModelScale(0)
	end
end
