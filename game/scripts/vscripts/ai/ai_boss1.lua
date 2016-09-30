--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 0.25 )
	thisEntity.ensnare = thisEntity:FindAbilityByName("dark_troll_warlord_ensnare")
end


function AIThink()
	local target = AICore:HighestThreatHeroInRange(thisEntity, thisEntity.ensnare:GetCastRange(), 15, true)
	if not target then target = AICore:NearestEnemyHeroInRange( thisEntity, thisEntity.ensnare:GetCastRange(), true) end
	if GetMapName() == "epic_boss_fight_boss_master" and boss_master then target = boss_master.lasttarget end
	if thisEntity.ensnare:IsFullyCastable() and target then
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			TargetIndex = target:entindex(),
			AbilityIndex = thisEntity.ensnare:entindex()
		})
		return 0.25
	end
	AICore:AttackHighestPriority( thisEntity )
	return 0.25
end