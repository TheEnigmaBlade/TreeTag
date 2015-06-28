function InitDummyHero(hero, playerId)
	PlayerResource:SetGold(playerId, 0, false)
	hero:SetAbilityPoints(0)
end

function InitGoodHero(hero, playerId)
	hero:SetAbilityPoints(START_LVLS_GOOD)
	
	for i = 0, 3 do
		local ability = hero:GetAbilityByIndex(i)
		ability:UpgradeAbility(true)
	end
	
	local item = CreateItem("item_build_gold_gen", hero, hero)
	hero:AddItem(item)
end

function InitBadHero(hero, playerId)
	hero:SetAbilityPoints(START_LVLS_BAD)
	
	--local ability = hero:GetAbilityByIndex(0)
	--ability:UpgradeAbility(true)
end

-- Called by the 'reset_dummy_pos' map entity entered by dummy hero
function ReturnDummyToCenter(keys)
	local entity = keys.activator
	if entity ~= nil then
		local unitName = entity:GetUnitName()
		
		-- It's a dummy unit! They shouldn't be leaving!
		if unitName == "npc_dota_hero_wisp" then
			GameMode:PrintH("Uh oh! A dummy hero is trying to leave the center!")
			
			local player = entity:GetOwner()
			local playerId = player:GetPlayerID()
			GameMode:Print("Player: " .. tostring(playerId), 1)
			
			entity:SetOrigin(Vector(0, 0, 0))
		end
	end
end
