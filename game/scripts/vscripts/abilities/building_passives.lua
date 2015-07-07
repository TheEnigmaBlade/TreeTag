function give_owner_gold(keys)
	local caster = keys.caster
	if caster.passivesEnabled then
		local player = caster:GetPlayerOwner()
		local playerId = player:GetPlayerID()
		local amount = keys.GoldAmount

		PlayerResource:ModifyGold(playerId, amount, false, DOTA_ModifyGold_GameTick)
	end
end

function grant_scout_vision(keys)
	local caster = keys.caster
	Timers:CreateTimer(function()
		if caster.passivesEnabled then
			--local team = caster:GetTeam()
			caster.scoutVisionUnit = CreateUnitByName("npc_scout_vision_dummy_unit", caster:GetOrigin(), false, nil, nil, DOTA_TEAM_GOODGUYS)
			--caster.scoutVisionUnit:SetOwner(caster)
			return nil
		end
		return 0.1
	end)
end

function remove_scout_vision(keys)
	local caster = keys.caster
	if caster.scoutVisionUnit then
		caster.scoutVisionUnit:Destroy()
		caster.scoutVisionUnit = nil
	end
end
