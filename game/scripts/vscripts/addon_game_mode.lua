-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('treetag')

function Precache(context)
--[[
	This function is used to precache resources/units/items/abilities that will be needed
	for sure in your game and that will not be precached by hero selection.	When a hero
	is selected from the hero selection screen, the game will precache that hero's assets,
	any equipped cosmetics, and perform the data-driven precaching defined in that hero's
	precache{} block, as well as the precache{} block for any equipped abilities.

	See GameMode:PostLoadPrecache() in gamemode.lua for more information
	]]

	DebugPrint("[BAREBONES] Performing pre-load precache")

	-- Particles can be precached individually or by folder
	-- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed
	PrecacheResource("particle", "particles/econ/items/effigies/status_fx_effigies/base_statue_destruction_gold.vpcf", context)
	PrecacheResource("particle", "particles/buildings/cpy_rune_bountygold.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_base_attack_explosion.vpcf", context)
	--PrecacheResource("particle_folder", "particles/test_particle", context)

	-- Models can also be precached by folder or individually
	-- PrecacheModel should generally used over PrecacheResource for individual models
	--PrecacheResource("model_folder", "particles/heroes/antimage", context)
	--PrecacheResource("model", "particles/heroes/viper/viper.vmdl", context)
	--PrecacheModel("models/heroes/viper/viper.vmdl", context)

	-- Sounds can precached here like anything else
	--PrecacheResource("soundfile", "sounds/physics/damage/building/radiant_tower_destruction_03.vsnd", context)

	-- Entire items can be precached by name
	-- Abilities can also be precached in this way despite the name
	--PrecacheItemByNameSync("example_ability", context)
	--PrecacheItemByNameSync("item_example_item", context)

	-- Entire heroes (sound effects/voice/models/particles) can be precached with PrecacheUnitByNameSync
	-- Custom units from npc_units_custom.txt can also have all of their abilities and precache{} blocks precached in this way
	PrecacheUnitByNameSync("npc_dota_hero_treant", context)
	PrecacheUnitByNameSync("npc_dota_hero_shredder", context)
	PrecacheUnitByNameSync("npc_dota_hero_wisp", context)
    PrecacheUnitByNameSync("npc_badguy_dummy", context)
	PrecacheUnitByNameSync("npc_wood_gatherer", context)
	
    -- Buildings
	PrecacheUnitByNameSync("npc_building_gold_gen", context)
	PrecacheUnitByNameSync("npc_building_scout_tower", context)
	PrecacheUnitByNameSync("npc_building_wall", context)
	PrecacheUnitByNameSync("npc_building_invisible_wall", context)
	PrecacheUnitByNameSync("npc_building_basic_tower", context)
	PrecacheUnitByNameSync("npc_building_barracks", context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.GameMode = GameMode()
	GameRules.GameMode:InitGameMode()
end
