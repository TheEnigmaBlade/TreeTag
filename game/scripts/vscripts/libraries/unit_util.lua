function LevelUpAllAbilities(unit)
	local N = unit:GetAbilityCount()
	for i = 0, N-1 do
		local ability = unit:GetAbilityByIndex(i)
		if ability ~= nil then
			ability:UpgradeAbility(true)
		end
	end
end
