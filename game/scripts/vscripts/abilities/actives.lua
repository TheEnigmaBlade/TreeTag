function Blink(keys)
	local hero = keys.caster
	local ability = keys.ability
	local range = keys.Range
	
	local targetPoint = keys.target_points[1]
	local heroPoint = hero:GetAbsOrigin()
	local diff = targetPoint - heroPoint
	
	if diff:Length2D() > range then
		targetPoint = heroPoint + (targetPoint - heroPoint):Normalized() * range
	end
	
	FindClearSpaceForUnit(hero, targetPoint, false)
end
