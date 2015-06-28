-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode


-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false

if GameMode == nil then
	_G.GameMode = class({})
end

require("libraries.logger")
require("libraries.timers")
require("libraries.notifications")
require("libraries.building_buddy")

require("internal.gamemode")
require("internal.events")

require("settings")
require("events")
require("treetag_settings")
require("treetag_functions")

--[[ INITIALIZATION ]]

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
	GameMode = self
	InitLogger(GameMode, "TREETAG")
	GameMode:PrintH("Loading gamemode...")

	-- Call the internal function to set up the rules/behaviors specified in constants.lua
	-- This also sets up event hooks for all event handlers in events.lua
	GameMode:_InitGameMode()

	-- Commands can be registered for debugging purposes or as functions that can be called by the custom UI
	Convars:RegisterCommand("give_gold", Dynamic_Wrap(GameMode, "CheatGoldCommand"), "Gold cheat", FCVAR_CHEAT)
	Convars:RegisterCommand("explore", Dynamic_Wrap(GameMode, "ExplorationCommand"), "Give current hero exploration mode", FCVAR_CHEAT)
	Convars:RegisterCommand("reset_cooldowns", Dynamic_Wrap(GameMode, "ResetCooldownsCommand"), "Reset current hero cooldowns", FCVAR_CHEAT)
	Convars:RegisterCommand("levelup", Dynamic_Wrap(GameMode, "LevelUpCommand"), "Level-up current hero", FCVAR_CHEAT)
	Convars:RegisterCommand("message_good_guys", Dynamic_Wrap(GameMode, "GoodGuyMessageCommand"), "Send a message to the good guys", FCVAR_CHEAT)
	Convars:RegisterCommand("message_bad_guys", Dynamic_Wrap(GameMode, "BadGuyMessageCommand"), "Send a message to the bad guys", FCVAR_CHEAT)
	
	-- Initialize BuildingHelper
	BuildingBuddy:Init()
	
	GameMode:PrintH("Done loading gamemode!\n")
end

--[[
	This function should be used to set up Async precache calls at the beginning of the gameplay.
	In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.	These calls will be made
	after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
	be used to precache dynamically-added datadriven abilities instead of items.	PrecacheUnitByNameAsync will
	precache the precache{} block statement of the unit and all precache{} block statements for every Ability#
	defined on the unit.
	This function should only be called once.	If you want to/need to precache more items/abilities/units at a later
	time, you can call the functions individually (for example if you want to precache units in a new wave of
	holdout).
	This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
	DebugPrint("[TREETAG] Performing Post-Load precache")
	--PrecacheItemByNameAsync("item_example_item", function(...) end)
	--PrecacheItemByNameAsync("example_ability", function(...) end)

	--PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
	--PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--[[
	This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
	It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
	GameMode:PrintH("First Player has loaded")
end

--[[
	This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
	It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
	GameMode:PrintH("All Players have loaded into the game")
	
	Timers:CreateTimer(10, function()
		Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, MESSAGE_HEADSTART_GOOD, 5, "GoodGuyMessage")
		Notifications:TopToTeam(DOTA_TEAM_BADGUYS, MESSAGE_HEADSTART_BAD, 5, "BadGuyMessage")
		
		for _, hero in pairs(Entities:FindAllByClassname("npc_dota_hero_wisp")) do
			local playerId = hero:GetPlayerOwnerID()
			local team = hero:GetTeam()
			
			local newHeroName, startGold
			if team == DOTA_TEAM_GOODGUYS then
				newHeroName = "npc_dota_hero_treant"
				startGold = START_GOLD_GOOD
			else
				newHeroName = "npc_dota_hero_shredder"
				startGold = START_GOLD_BAD
			end
			
			GameMode:Print("Player " .. tostring(playerId) .. " is on team " .. tostring(team) .. " and gets " .. newHeroName, 1)
			PlayerResource:ReplaceHeroWith(playerId, newHeroName, startGold, 0)
		end
	end)
end

-- Initialize a hero when it spawns for the first time
function GameMode:OnHeroInGame(hero)
	local heroName = hero:GetUnitName()
	local playerId = hero:GetPlayerOwnerID()
	
	-- Initialize dummy state
	if heroName == "npc_dota_hero_wisp" then
		GameMode:PrintH("Initializing player " .. tostring(playerId) .. " dummy")
		InitDummyHero(hero, playerId)
		return
	end
	
	-- Initialize actual hero
	GameMode:PrintH("Initializing player hero")
	
	local team = hero:GetTeam()
	GameMode:Print("Hero: " .. hero:GetUnitName(), 1)
	GameMode:Print("Player: " .. tostring(playerId), 1)
	GameMode:Print("Team: " .. tostring(team), 1)
	
	if team == DOTA_TEAM_GOODGUYS then
		GameMode:Print("They're a good guy!", 1)
		InitGoodHero(hero, playerId)
	else
		GameMode:Print("They're a BAAAAD guy!", 1)
		InitBadHero(hero)
	end
end

-- Start the game
function GameMode:OnGameInProgress()
	GameMode:Print("The game has begun")
	
	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, MESSAGE_START_GOOD, 5, "GoodGuyMessage")
	Notifications:TopToTeam(DOTA_TEAM_BADGUYS, MESSAGE_START_BAD, 5, "BadGuyMessage")
	
	--[[for _, hero in pairs(Entities:FindAllByClassname("npc_dota_hero_wisp")) do
		local playerId = hero:GetPlayerOwnerID()
		local team = hero:GetTeam()
		
		local newHeroName = "npc_dota_hero_shredder"
		local startGold = START_GOLD_BAD
		
		GameMode:Print("Player " .. tostring(playerId) .. " is on team " .. tostring(team) .. " and gets " .. newHeroName, 1)
		PlayerResource:ReplaceHeroWith(playerId, newHeroName, startGold, 0)
	end]]
end


--[[ DEBUG/CHEAT COMMANDS ]]

-- This is an example console command
function GameMode:CheatGoldCommand()
	local cmdPlayer = Convars:GetCommandClient()
	if cmdPlayer then
		local playerId = cmdPlayer:GetPlayerID()
		if playerId ~= nil and playerId ~= -1 then
			PlayerResource:ModifyGold(playerId, 100, false, DOTA_ModifyGold_CheatCommand)
		end
	end
end

function GameMode:ExplorationCommand()
	local cmdPlayer = Convars:GetCommandClient()
	if cmdPlayer then
		local playerId = cmdPlayer:GetPlayerID()
		if playerId ~= nil and playerId ~= -1 then
			local hero = cmdPlayer:GetAssignedHero()
			hero:SetBaseMoveSpeed(600)
		end
	end
end

function GameMode:ResetCooldownsCommand()
	local cmdPlayer = Convars:GetCommandClient()
	if cmdPlayer then
		local playerId = cmdPlayer:GetPlayerID()
		if playerId ~= nil and playerId ~= -1 then
			local hero = cmdPlayer:GetAssignedHero()
			for i = 0, 3 do
				local ability = hero:GetAbilityByIndex(i)
				ability:EndCooldown()
			end
		end
	end
end

function GameMode:LevelUpCommand()
	local cmdPlayer = Convars:GetCommandClient()
	if cmdPlayer then
		local playerId = cmdPlayer:GetPlayerID()
		if playerId ~= nil and playerId ~= -1 then
			local hero = cmdPlayer:GetAssignedHero()
			hero:HeroLevelUp(true)
		end
	end
end

function GameMode:GoodGuyMessageCommand()
	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, "Test is a test message for good guys!", 10, "GoodGuyMessage")
end

function GameMode:BadGuyMessageCommand()
	Notifications:TopToTeam(DOTA_TEAM_BADGUYS, "Test is a test message for bad guys!", 10, "BadGuyMessage")
end
