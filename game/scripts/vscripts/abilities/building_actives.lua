function UpgradeAbility(keys)
	local caster = keys.caster
	local abilityName = keys.AbilityName
	
	local ability = caster:FindAbilityByName(abilityName)
	ability:UpgradeAbility(true)
end
