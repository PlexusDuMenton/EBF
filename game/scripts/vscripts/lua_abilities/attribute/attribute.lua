
if shield_faith == nil then
	shield_faith = class({})
end

LinkLuaModifier( "shield_faith_modifier", "skill/shield_faith/shield_faith_modifier.lua", LUA_MODIFIER_MOTION_NONE )

function shield_faith:GetIntrinsicModifierName()
	return "shield_faith_modifier"
end