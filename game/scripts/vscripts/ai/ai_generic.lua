--[[
Broodking AI
]]

require( "ai/ai_core" )

-- GENERIC AI FOR SIMPLE CHASE ATTACKERS

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 1 )
end


function AIThink()
	AICore:AttackHighestPriority( thisEntity )
	return 0.25
end