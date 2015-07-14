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
	local wisp = keys.caster
	local tree = keys.target
	
	if tree.attachedWisp == nil then
		local treeOrigin = tree:GetOrigin()
		wisp:SetOrigin(treeOrigin)
		
		if wisp.attachedTree ~= nil then
			wisp.attachedTree.attachedWisp = nil
		end
		wisp.attachedTree = tree
		tree.attachedWisp = wisp
	else
		wisp:RemoveModifierByName("modifier_gathering_wood")
	end
end

function StopWoodGather(keys)
	GameMode:PrintH("Stopping wood gathering")
	GameMode:PrintTable(keys)
	local wisp = keys.caster
	local tree = wisp.attachedTree
	
	FindClearSpaceForUnit(wisp, wisp:GetOrigin(), true)
	
	wisp.attachedTree = nil
	if tree ~= nil then
		tree.attachedWisp = nil
	end
end

function GatherWood(keys)
	local wisp = keys.caster
	local tree = wisp.attachedTree
	if not tree:IsStanding() then
		-- Abort gathering if our tree is gone!
		wisp:RemoveModifierByName("modifier_gathering_wood")
		StopWoodGather(keys)
	else
		-- Continue magically gathering wood
		local player = wisp:GetPlayerOwner()
		ChangePlayerWood(player, 1)
	end
end
