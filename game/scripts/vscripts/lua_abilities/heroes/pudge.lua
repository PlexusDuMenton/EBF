pudge_dismember_lua = class({})
LinkLuaModifier( "pudge_dismember", "lua_abilities/heroes/modifiers/pudge_dismember.lua" ,LUA_MODIFIER_MOTION_NONE )

--[[Author: Valve
	Date: 26.09.2015.]]
--------------------------------------------------------------------------------

function pudge_dismember_lua:GetConceptRecipientType()
	return DOTA_SPEECH_USER_ALL
end

--------------------------------------------------------------------------------

function pudge_dismember_lua:SpeakTrigger()
	return DOTA_ABILITY_SPEAK_CAST
end

--------------------------------------------------------------------------------

function pudge_dismember_lua:GetChannelTime()
	self.duration = self:GetSpecialValueFor( "duration" )

	if IsServer() then
		if self.hVictim ~= nil then
			return self.duration
		end

		return 0.0
	end

	return self.duration
end

--------------------------------------------------------------------------------

function pudge_dismember_lua:OnAbilityPhaseStart()
	if IsServer() then
		self.hVictim = self:GetCursorTarget()
	end

	return true
end

--------------------------------------------------------------------------------

function pudge_dismember_lua:OnSpellStart()
	if self.hVictim == nil then
		return
	end

	if self.hVictim:TriggerSpellAbsorb( self ) then
		self.hVictim = nil
		self:GetCaster():Interrupt()
	else
		self.hVictim:AddNewModifier( self:GetCaster(), self,  "pudge_dismember", { duration = 999} )
		self.hVictim:Interrupt()
	end
end


--------------------------------------------------------------------------------

function pudge_dismember_lua:OnChannelFinish( bInterrupted )
	if self.hVictim ~= nil then
		self.hVictim:RemoveModifierByName("pudge_dismember" )
	end
end

--------------------------------------------------------------------------------