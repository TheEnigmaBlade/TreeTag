DEBUG_MODE = true				-- Note to self: disable before release
BAREBONES_DEBUG_SPEW = false

if GameMode == nil then
	_G.GameMode = class({})
end

require("libraries.logger")
require("libraries.timers")
require("libraries.notifications")
require("libraries.building_buddy")
require("libraries.unit_buddy")
require("libraries.unit_util")

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
	Convars:RegisterCommand("message_good_guys", Dynamic_Wrap(GameMode, "GameMode:GoodGuyMessageCommand"), "Send a message to the good guys", FCVAR_CHEAT)
	Convars:RegisterCommand("message_bad_guys", Dynamic_Wrap(GameMode, "GameMode:BadGuyMessageCommand"), "Send a message to the bad guys", FCVAR_CHEAT)
	Convars:RegisterCommand("spawn_badguy", Dynamic_Wrap(GameMode, "SpawnBadGuy"), "Spawn a bad guy", FCVAR_CHEAT)
	
	-- Initialize libraries
	BuildingBuddy:Init()
	UnitBuddy:Init()
	
	-- Game variables
	GameMode.deadGoodGuys = 0
	GameMode.deadBadGuys = 0
	
	GameMode.playerWood = {}
	for i = 0, 10 do
		GameMode.playerWood[i] = 0
	end
	
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
	--GameMode:PrintH("Performing Post-Load precache")
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
	
	local waitTime
	if DEBUG_MODE then
		waitTime = 0
	else
		waitTime = 5
	end
	
	Timers:CreateTimer(waitTime, function()
		GoodGuyMessage(MESSAGE_HEADSTART_GOOD, 5)
		BadGuyMessage(MESSAGE_HEADSTART_BAD, 5)
		
		for _, hero in pairs(Entities:FindAllByClassname(HERO_DUMMY)) do
			local playerId = hero:GetPlayerOwnerID()
			local team = hero:GetTeam()
			
			if team == DOTA_TEAM_GOODGUYS then
				GameMode:Print("Player " .. tostring(playerId) .. " is a good guy and has their hero", 1)
				PlayerResource:ReplaceHeroWith(playerId, HERO_GOOD, START_GOLD_GOOD, 0)
			elseif DEBUG_MODE then
				GameMode:Print("Player " .. tostring(playerId) .. " is a bad guy and has their hero", 1)
				PlayerResource:ReplaceHeroWith(playerId, HERO_BAD, START_GOLD_BAD, 0)
			end
		end
	end)
end

-- Initialize a hero when it spawns for the first time
function GameMode:OnHeroInGame(hero)
	local heroName = hero:GetUnitName()
	local playerId = hero:GetPlayerOwnerID()
	
	-- Initialize dummy state
	if heroName == HERO_DUMMY then
		GameMode:PrintH("Initializing player " .. tostring(playerId) .. " dummy")
		PlayerResource:SetGold(playerId, 0, false)
		InitDummyHero(hero)
		return
	end
	
	-- Initialize actual hero
	GameMode:PrintH("Initializing player hero")
	UnitBuddy:InitUnit(hero)
	
	local team = hero:GetTeam()
	GameMode:Print("Hero: " .. hero:GetUnitName(), 1)
	GameMode:Print("Player: " .. tostring(playerId), 1)
	GameMode:Print("Team: " .. tostring(team), 1)
	
	if team == DOTA_TEAM_GOODGUYS then
		GameMode:Print("They're a good guy!", 1)
		InitGoodHero(hero)
	else
		GameMode:Print("They're a BAAAAD guy!", 1)
		InitBadHero(hero)
	end
end

function GameMode:OnHeroDeath(victim, killer)
	local victimTeam = victim:GetTeam()
	if victimTeam == DOTA_TEAM_GOODGUYS then
		GameMode.deadGoodGuys = GameMode.deadGoodGuys + 1
		if GameMode.deadGoodGuys == PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) then
			GameMode:EndGame(DOTA_TEAM_BADGUYS)
		end
		
		GoodGuyMessage(MESSAGE_GOOD_DEATH_GOOD, 5)
		BadGuyMessage(MESSAGE_GOOD_DEATH_BAD, 5)
	else
		GameMode.deadBadGuys = GameMode.deadBadGuys + 1
		
		GoodGuyMessage(MESSAGE_BAD_DEATH_GOOD, 5)
		BadGuyMessage(MESSAGE_BAD_DEATH_BAD, 5)
	end
end

function GameMode:OnHeroRespawn(hero)
	local heroName = hero:GetUnitName()
	local playerId = hero:GetPlayerOwnerID()
	local team = hero:GetTeam()
	GameMode:PrintH("Hero respawned: " .. heroName .. " on team " .. tostring(team))
	GameMode:Print("Model scale = " .. tostring(hero:GetModelScale()), 1)
	
	if team == DOTA_TEAM_GOODGUYS then
		GameMode.deadGoodGuys = GameMode.deadGoodGuys - 1
		local playerGold = PlayerResource:GetGold(playerId)
		local hero = PlayerResource:ReplaceHeroWith(playerId, HERO_DUMMY, playerGold, 0)
		InitDummyHero(hero)
	else
		GameMode.deadBadGuys = GameMode.deadBadGuys - 1
	end
	
	UnitBuddy:InitUnit(hero)
end

-- Start the game
function GameMode:OnGameInProgress()
	GameMode:Print("The game has begun")
	
	GoodGuyMessage(MESSAGE_START_GOOD, 5)
	BadGuyMessage(MESSAGE_START_BAD, 5)
	
	-- Finish granting actual heroes
	for _, hero in pairs(Entities:FindAllByClassname(HERO_DUMMY)) do
		local playerId = hero:GetPlayerOwnerID()
		if playerId >= 0 then
			local team = hero:GetTeam()
			
			if team == DOTA_TEAM_BADGUYS then
				GameMode:Print("Player " .. tostring(playerId) .. " is a bad guy and has their hero", 1)
				PlayerResource:ReplaceHeroWith(playerId, HERO_BAD, START_GOLD_BAD, 0)
			end
		end
	end
	
	-- Start regular updates to bad guys
	local updateIndex = 1
	Timers:CreateTimer(UPDATE_PERIOD, function()
		GameMode:PrintH("Regular update #" .. tostring(updateIndex) .. " triggered (period=" .. tostring(UPDATE_PERIOD) .. ")")
		
		-- Give experience to bad guys (because they're probaby sucking)
		local addExp = UPDATE_EXP_BASE * updateIndex
		for playerId = 0, 9 do
			local player = PlayerResource:GetPlayer(playerId)
			if player ~= nil and player:GetTeam() == DOTA_TEAM_BADGUYS then
				GameMode:Print("Updating hero owned by player " .. tostring(playerId), 1)
				
				local hero = player:GetAssignedHero()
				GameMode:Print("Hero: " .. hero:GetUnitName(), 2)
				hero:AddExperience(addExp, DOTA_ModifyXP_Unspecified, false, false)
				
				-- While we're at it, give them some bonus movement speed
				--hero:SetBaseMoveSpeed(hero:GetBaseMoveSpeed() + UPDATE_MOVESPEED)
			end
		end
		
		-- Pick some messages and send them to the players
		local msgsBad = UPDATE_MESSAGES_BAD[updateIndex]
		local msgBad = msgsBad[math.random(#msgsBad)]
		BadGuyMessage(msgBad, 5)
		
		local msgsGood = UPDATE_MESSAGES_GOOD[updateIndex]
		local msgGood = msgsGood[math.random(#msgsGood)]
		GoodGuyMessage(msgGood, 5)
		
		-- End of updates
		updateIndex = updateIndex + 1
		if updateIndex <= NUM_UPDATES then
			return UPDATE_PERIOD
		end
		return nil
	end)
	
	-- Start time-based win condition
	Timers:CreateTimer(GAME_LENGTH, function()
		GameMode:PrintH("Game win condition met: time (trees win!)")
		GameMode:EndGame(DOTA_TEAM_GOODGUYS)
		return nil
	end)
end

function GameMode:EndGame(winningTeam)
	GameRules:SetSafeToLeave(true)
	GameRules:SetGameWinner(winningTeam)
	local loser
	if winningTeam == DOTA_TEAM_GOODGUYS then
		loser = DOTA_TEAM_BADGUYS
	else
		loser = DOTA_TEAM_GOODGUYS
	end
	GameRules:MakeTeamLose(loser)
end

-- Initialize special units
function GameMode:OnUnitInGame(unit)
	UnitBuddy:InitUnit(unit)
	local isBuilding = UnitBuddy:IsBuilding(unit)
	
	-- Level up all abilities of buildings and others
	local unitName = unit:GetUnitName()
	if isBuilding or InArray(AUTO_LEVEL_UNITS, unitName) then
		LevelUpAllAbilities(unit)
	end
	
	-- Apply the building modifier
	if isBuilding then
		local modifiers = CreateItem("item_modifier_master", nil, nil)
		modifiers:ApplyDataDrivenModifier(unit, unit, "is_building", {})
	else
		CreateLifeParticles(unit)
	end
end

-- An entity somewhere has been hurt.
function GameMode:OnEntityHurt(keys)
	--GameMode:PrintH("Entity Hurt")

	local damagebits = keys.damagebits -- This might always be 0 and therefore useless
	local entCause = nil
	if keys.entindex_attacker ~= nil then
		entCause = EntIndexToHScript(keys.entindex_attacker)
	end
	local entVictim = EntIndexToHScript(keys.entindex_killed)
	
	if entCause ~= nil and entVictim:IsAlive() then
		if entVictim:IsRealHero() then
			-- Check if victim is a dummy and should be revived
			local victimName = entVictim:GetUnitName()
			local causeTeam = entCause:GetTeamNumber()
			if victimName == HERO_DUMMY then
				if causeTeam == DOTA_TEAM_GOODGUYS then
					local playerGold = PlayerResource:GetGold(playerId)
					PlayerResource:ReplaceHeroWith(playerId, HERO_DUMMY, playerGold, 0)
				else
					entCause:Kill(nil, entCause)
				end
			end
		else
			-- Check if victim is a building and attacker is its owner
			local causePlayerId = entCause:GetPlayerOwnerID()
			local victimPlayerId = entVictim:GetPlayerOwnerID()
			--local causePlayerId
			--if entCause[GetPlayerID] ~= nil then
				-- Attacked by hero
			--	causePlayerId = entCause:GetPlayerID()
			--else
				-- Attacked by non-hero unit (like a tower)
			--	causePlayerId = entCause:GetOwner():GetPlayerID()
			--end
			--local victimPlayerId = entVictim:GetOwner():GetPlayerID()
			GameMode:Print("Cause player ID: " .. tostring(causePlayerId), 1)
			GameMode:Print("Victim player ID: " .. tostring(victimPlayerId), 1)
			
			if causePlayerId == victimPlayerId then
				entVictim:Kill(nil, entCause)
			end
		end
	end
end

function GameMode:OnPlayerDeny(keys)
	GameMode:PrintH("Player deny event")
	GameMode:PrintTable(keys)
end

function GameMode:OnMoneyChanged(keys)
	--GameMode:PrintH("Money changed")
	--GameMode:PrintTable(keys)
	--TODO: maybe add gold next to wood in HUD
end

-- Message utils
function GoodGuyMessage(msg, length)
	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text=msg, duration=length, class="GoodGuyMessage"})
end

function BadGuyMessage(msg, length)
	Notifications:TopToTeam(DOTA_TEAM_BADGUYS, {text=msg, duration=length, class="BadGuyMessage"})
end

function ErrorMessage(msg, player)
	Notifications:Bottom(player, {text=msg, duration=1, class="AbilityError"})
end

--[[ DEBUG/CHEAT COMMANDS ]]

-- This is an example console command
function GameMode:CheatGoldCommand()
	local cmdPlayer = Convars:GetCommandClient()
	if cmdPlayer then
		local playerId = cmdPlayer:GetPlayerID()
		if playerId ~= nil and playerId ~= -1 then
			PlayerResource:ModifyGold(playerId, 1000, false, DOTA_ModifyGold_CheatCommand)
		end
	end
end

function GameMode:ExplorationCommand()
	local cmdPlayer = Convars:GetCommandClient()
	if cmdPlayer then
		local playerId = cmdPlayer:GetPlayerID()
		if playerId ~= nil and playerId ~= -1 then
			local hero = cmdPlayer:GetAssignedHero()
			hero:SetBaseMoveSpeed(800)
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
	GoodGuyMessage("Test is a test message for good guys!", 10)
end

function GameMode:BadGuyMessageCommand()
	BadGuyMessage("Test is a test message for bad guys!", 10)
end

function GameMode:SpawnBadGuy()
	CreateUnitByName("npc_badguy_dummy", Vector(0, 0, 0), false, nil, nil, DOTA_TEAM_BADGUYS)
end
