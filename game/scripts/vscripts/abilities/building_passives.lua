function give_owner_gold(keys)
	local caster = keys.caster
	
	if caster.passivesEnabled then
		local player = caster:GetPlayerOwner()
		local playerId = player:GetPlayerID()
		local amount = keys.GoldAmount
		
		PlayerResource:ModifyGold(playerId, amount, false, DOTA_ModifyGold_GameTick)
	end
end
