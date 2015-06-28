--[[ Tree tracking ]]

destroyed_trees = {}

function AddDestroyedTree(tree)
	local origin = tree:GetOrigin()
	destroyed_trees[origin] = tree
end

function RemoveDestroyedTree(tree)
	local origin = tree:GetOrigin()
	destroyed_trees[origin] = nil
end

function GetDestroyedTreesAroundPoint(point, radius)
	trees = {}
	for origin, tree in pairs(destroyed_trees) do
		dist = (point - origin):Length2D()
		if dist <= radius then
			table.insert(trees, tree)
		end
	end
	return trees
end

-- [[ Spell functions ]]

function DestroyTree(event)
	local caster = event.caster
	local caster_team = caster:GetTeam()
	local target = event.target
	
	target:CutDown(caster_team)
	AddDestroyedTree(target)
end

function DestroyTreeAoE(event)
	local caster = event.caster
	local caster_team = caster:GetTeam()
	local target_point = event.target_points[1]
	local radius = event.Radius
	
	local trees = GridNav:GetAllTreesAroundPoint(target_point, radius, false)
	for i, tree in ipairs(trees) do
		tree:CutDown(caster_team)
		AddDestroyedTree(tree)
	end
end

function RegrowTreeAoE(event)
	local target_point = event.target_points[1]
	local radius = event.Radius
	
	local trees = GetDestroyedTreesAroundPoint(target_point, radius)
	for i, tree in ipairs(trees) do
		tree:GrowBack()
		RemoveDestroyedTree(tree)
	end
end
