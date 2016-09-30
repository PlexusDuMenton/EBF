
if lua_attribute_bonus == nil then
	lua_attribute_bonus = class({})
end

LinkLuaModifier( "lua_attribute_bonus_modifier", "lua_abilities/attribute/lua_attribute_bonus_modifier.lua", LUA_MODIFIER_MOTION_NONE )
-- LinkLuaModifier( "lua_attribute_bonus_heal_received", "lua_abilities/attribute/lua_attribute_bonus_heal_received.lua", LUA_MODIFIER_MOTION_NONE )

function lua_attribute_bonus:GetIntrinsicModifierName()
	return "lua_attribute_bonus_modifier"
end

function lua_attribute_bonus:OnUpgrade()
	self:GetCaster():RemoveModifierByName("lua_attribute_bonus_modifier")
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "lua_attribute_bonus_modifier", {})
end