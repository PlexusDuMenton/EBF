modifier_boss_damagedecrease = class({})

function modifier_boss_damagedecrease:IsHidden()
	return true
end

function modifier_boss_damagedecrease:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_boss_damagedecrease:GetModifierIncomingDamage_Percentage( params )
	if GameRules._NewGamePlus then
		return -70
	else
		return -35
	end
end


