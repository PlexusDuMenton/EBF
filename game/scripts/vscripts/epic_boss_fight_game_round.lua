--[[
	CHoldoutGameRound - A single round of Holdout
]]

if CHoldoutGameRound == nil then
	CHoldoutGameRound = class({})
end
require( "libraries/Timers" )
require("internal/util")


function CHoldoutGameRound:ReadConfiguration( kv, gameMode, roundNumber )
	self._gameMode = gameMode
	self._nRoundNumber = roundNumber
	self._szRoundQuestTitle = kv.round_quest_title or "#DOTA_Quest_Holdout_Round"
	self._szRoundTitle = kv.round_title or string.format( "Round%d", roundNumber )

	self._nMaxGold = tonumber( kv.MaxGold or 0 )
	self._nBagCount = tonumber( kv.BagCount or 0 )
	self._nBagVariance = tonumber( kv.BagVariance or 0 )
	self._nFixedXP = tonumber( kv.FixedXP or 0 )

	self._vSpawners = {}
	for k, v in pairs( kv ) do
		if type( v ) == "table" and v.NPCName then
			local spawner = CHoldoutGameSpawner()
			spawner:ReadConfiguration( k, v, self )
			self._vSpawners[ k ] = spawner
		end
	end

	for _, spawner in pairs( self._vSpawners ) do
		spawner:PostLoad( self._vSpawners )
	end
end


function CHoldoutGameRound:Precache()
	for _, spawner in pairs( self._vSpawners ) do
		spawner:Precache()
	end
end

--[[function CHoldoutGameRound:spawn_treasure()
	local Item_spawn = CreateItem( "item_present_treasure", nil, nil )
	Timers:CreateTimer(0.03,function()
		local max_player = DOTA_MAX_TEAM_PLAYERS
		WID = math.RandomInt(0,max_player)
		if PlayerResource:GetConnectionState(WID) == 2 then
			local player = PlayerResource:GetPlayer(WID)
			local hero = player:GetAssignedHero() 
			hero:AddItem(Item_spawn)
		else
			return 0.03
		end
	end)
end]]

function CHoldoutGameRound:Begin()
	
	self._vEnemiesRemaining = {}
	self._vEventHandles = {
		ListenToGameEvent( "npc_spawned", Dynamic_Wrap( CHoldoutGameRound, "OnNPCSpawned" ), self ),
		ListenToGameEvent( "entity_killed", Dynamic_Wrap( CHoldoutGameRound, "OnEntityKilled" ), self ),
		ListenToGameEvent( "dota_holdout_revive_complete", Dynamic_Wrap( CHoldoutGameRound, 'OnHoldoutReviveComplete' ), self )
	}
	self._DisconnectedPlayer = 0
	self._nAsuraCoreRemaining = 0

	local PlayerNumber = PlayerResource:GetTeamPlayerCount() 
	print (PlayerNumber)
	local GoldMultiplier = (((PlayerNumber-self._DisconnectedPlayer)+0.56)/1.8)*0.15
	print (GoldMultiplier)

	ListenToGameEvent( "player_reconnected", Dynamic_Wrap( CHoldoutGameRound, 'OnPlayerReconnected' ), self )
	ListenToGameEvent( "player_disconnect", Dynamic_Wrap( CHoldoutGameRound, 'OnPlayerDisconnected' ), self )


	local roundNumber = self._nRoundNumber
	self._nGoldRemainingInRound = self._nMaxGold * GoldMultiplier * 1.1
	if GameRules._NewGamePlus == true then
		self._nGoldRemainingInRound = (self._nGoldRemainingInRound + 30000) * (roundNumber^0.4)
		print (self._nGoldRemainingInRound)
		if self._nGoldRemainingInRound > 75000 then
			while self._nGoldRemainingInRound > 50000 do
				print ("adding on asura core", self._nAsuraCoreRemaining)
				self._nGoldRemainingInRound = self._nGoldRemainingInRound- 50000
				self._nAsuraCoreRemaining = self._nAsuraCoreRemaining + 1 
			end
			self._nAsuraCoreRemaining = math.ceil(self._nAsuraCoreRemaining/(PlayerNumber-self._DisconnectedPlayer))
			print (self._nAsuraCoreRemaining)
		end
	end

	self._nGoldBagsRemaining = self._nBagCount
	self._nGoldBagsExpired = 0
	self._nCoreUnitsTotal = 0
	if GameRules._NewGamePlus == true then
		self._nFixedXP = (500000 + self._nFixedXP) * (roundNumber^0.3+1)
	end
	self._nExpRemainingInRound = self._nFixedXP
	for _, spawner in pairs( self._vSpawners ) do
		spawner:Begin()
		self._nCoreUnitsTotal = self._nCoreUnitsTotal + spawner:GetTotalUnitsToSpawn()
		if self._nRoundNumber == 36 then
			self._nCoreUnitsTotal = self._nCoreUnitsTotal + 1
		end
	end
	self._nCoreUnitsKilled = 0

	self._entQuest = SpawnEntityFromTableSynchronous( "quest", {
		name = self._szRoundTitle,
		title =  self._szRoundQuestTitle
	})
	self._entQuest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_ROUND, self._nRoundNumber )
	self._entQuest:SetTextReplaceString( self._gameMode:GetDifficultyString() )

	self._entKillCountSubquest = SpawnEntityFromTableSynchronous( "subquest_base", {
		show_progress_bar = true,
		progress_bar_hue_shift = -119
	} )
	self._entQuest:AddSubquest( self._entKillCountSubquest )
	self._entKillCountSubquest:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, self._nCoreUnitsTotal )
end

function CHoldoutGameRound:OnHoldoutReviveComplete( event )
	local castingHero = EntIndexToHScript( event.caster )
	
	if castingHero then
		castingHero.Ressurect = castingHero.Ressurect + 1
		local totalgold = castingHero:GetGold() + self._nRoundNumber*5
	            castingHero:SetGold(0 , false)
	            castingHero:SetGold(totalgold, true)
	end
end

function CHoldoutGameRound:End()
	for _, eID in pairs( self._vEventHandles ) do
		StopListeningToGameEvent( eID )
	end
	self._vEventHandles = {}

	for _,unit in pairs( FindUnitsInRadius( DOTA_TEAM_BADGUYS, Vector( 0, 0, 0 ), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )) do
		if not unit:IsTower() or unit:IsHero() == false then
			UTIL_Remove( unit )
		end
	end

	for _,spawner in pairs( self._vSpawners ) do
		spawner:End()
	end

	if self._entQuest then
		UTIL_Remove( self._entQuest )
		self._entQuest = nil
		self._entKillCountSubquest = nil
	end
end


function CHoldoutGameRound:Think()
	for _, spawner in pairs( self._vSpawners ) do
		spawner:Think()
	end
end


function CHoldoutGameRound:ChooseRandomSpawnInfo()
	return self._gameMode:ChooseRandomSpawnInfo()
end


function CHoldoutGameRound:IsFinished()
	for _, spawner in pairs( self._vSpawners ) do
		if not spawner:IsFinishedSpawning() then
			return false
		end
	end
	local nEnemiesRemaining = #self._vEnemiesRemaining
	if nEnemiesRemaining == 0 then
		return true
	end

	if not self._lastEnemiesRemaining == nEnemiesRemaining then
		self._lastEnemiesRemaining = nEnemiesRemaining
		print ( string.format( "%d enemies remaining in the round...", #self._vEnemiesRemaining ) )
	end
	return false
end


-- Rather than use the xp granting from the units keyvalues file,
-- we let the round determine the xp per unit to grant as a flat value.
-- This is done to make tuning of rounds easier.


function CHoldoutGameRound:OnNPCSpawned( event )
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if not spawnedUnit or spawnedUnit:IsPhantom() or spawnedUnit:GetClassname() == "npc_dota_thinker" or spawnedUnit:GetUnitName() == "" then
		return
	end
	local nCoreUnitsRemaining = self._nCoreUnitsTotal - self._nCoreUnitsKilled

	if spawnedUnit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
		table.insert( self._vEnemiesRemaining, spawnedUnit )
		if self._nAsuraCoreRemaining>0 then
			if nCoreUnitsRemaining > 1 then
				spawnedUnit.Asura_To_Give = 1
				self._nAsuraCoreRemaining = self._nAsuraCoreRemaining - 1
			elseif nCoreUnitsRemaining <= 1 then
				spawnedUnit.Asura_To_Give = self._nAsuraCoreRemaining
				self._nAsuraCoreRemaining = 0
			end
		end
		local ability = spawnedUnit:FindAbilityByName("true_sight_boss")
		if not ability ~= nil then
			if GetMapName() == "epic_boss_fight_impossible" or GetMapName() == "epic_boss_fight_challenger" or GetMapName() == "epic_boss_fight_boss_master" then spawnedUnit:AddAbility('true_sight_boss') end
		end
		spawnedUnit:SetDeathXP( 0 )
		spawnedUnit.unitName = spawnedUnit:GetUnitName()

	end
end


function CHoldoutGameRound:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	if not killedUnit then
		return
	end
	for i, unit in pairs( self._vEnemiesRemaining ) do
		if killedUnit == unit then
			table.remove( self._vEnemiesRemaining, i )
			break
		end
	end	
	if killedUnit.Holdout_IsCore then
		self._nCoreUnitsKilled = self._nCoreUnitsKilled + 1
		self:_CheckForGoldBagDrop( killedUnit )
		local nCoreUnitsRemaining = self._nCoreUnitsTotal - self._nCoreUnitsKilled
		if nCoreUnitsRemaining == 0 then
			--self:spawn_treasure()
		end
	end
end



function CHoldoutGameRound:_CheckForGoldBagDrop( killedUnit )
	if self._nGoldRemainingInRound <= 0 then
		return
	end

	local nGoldToDrop = 0
	local nCoreUnitsRemaining = self._nCoreUnitsTotal - self._nCoreUnitsKilled
	local PlayerNumber = PlayerResource:GetTeamPlayerCount()
	local exptogain = 0
	if nCoreUnitsRemaining > 0 then
		exptogain = ( (self._nFixedXP) / (self._nCoreUnitsTotal) )
	elseif nCoreUnitsRemaining <= 0 then
		exptogain = self._nExpRemainingInRound
	end
	for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
		if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
			unit:AddExperience (exptogain,false,false)
		end
	end
	if nCoreUnitsRemaining <= 0 then
		nGoldToDrop = self._nGoldRemainingInRound
	else
		local flCurrentDropChance = self._nGoldBagsRemaining / (1 + nCoreUnitsRemaining)
		if RandomFloat( 0, 1 ) <= flCurrentDropChance then
			if self._nGoldBagsRemaining <= 1 then
				nGoldToDrop = self._nGoldRemainingInRound
			else
				nGoldToDrop = math.floor( self._nGoldRemainingInRound / self._nGoldBagsRemaining )
				nCurrentGoldDrop = math.max(1, RandomInt( nGoldToDrop - self._nBagVariance, nGoldToDrop + self._nBagVariance  ) )
			end
		end
	end
	
	nGoldToDrop = math.min( nGoldToDrop, self._nGoldRemainingInRound )
	if nGoldToDrop <= 0 then
		return
	end
	self._nGoldRemainingInRound = math.max( 0, self._nGoldRemainingInRound - nGoldToDrop )
	self._nGoldBagsRemaining = math.max( 0, self._nGoldBagsRemaining - 1 )
	self._nExpRemainingInRound = math.max( 0,self._nExpRemainingInRound - exptogain)

	local newItem = CreateItem( "item_bag_of_gold", nil, nil )
	newItem:SetPurchaseTime( 0 )
	newItem:SetCurrentCharges( nGoldToDrop )
	local drop = CreateItemOnPositionSync( killedUnit:GetAbsOrigin(), newItem )
	local dropTarget = killedUnit:GetAbsOrigin() + RandomVector( RandomFloat( 50, 350 ) )
	newItem:LaunchLoot( true, 750, 0.75, dropTarget )
end


function CHoldoutGameRound:StatusReport( )
	print( string.format( "Enemies remaining: %d", #self._vEnemiesRemaining ) )
	for _,e in pairs( self._vEnemiesRemaining ) do
		if e:IsNull() then
			print( string.format( "<Unit %s Deleted from C++>", e.unitName ) )
		else
			print( e:GetUnitName() )
		end
	end
	print( string.format( "Spawners: %d", #self._vSpawners ) )
	for _,s in pairs( self._vSpawners ) do
		s:StatusReport()
	end
end