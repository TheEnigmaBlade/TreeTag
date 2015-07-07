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

function StartWoodGather(keys)
	GameMode:PrintH("Starting wood gathering")
	GameMode:PrintTable(keys)
	local caster = keys.caster
	local tree = keys.target
	
	--TODO: check if tree already has a wisp
	local treeOrigin = tree:GetOrigin()
	caster:SetOrigin(treeOrigin)
end

function StopWoodGather(keys)
	GameMode:PrintH("Stopping wood gathering")
	GameMode:PrintTable(keys)
	local caster = keys.caster
	FindClearSpaceForUnit(caster, caster:GetOrigin(), true)
end

function GatherWood(keys)
	--TODO: check if the tree exists, stop if it doesn't
	local caster = keys.caster
	local player = caster:GetPlayerOwner()
	local playerId = caster:GetPlayerOwnerID()
	ChangePlayerWood(player, 1)
end
