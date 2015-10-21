if lua_attribute_bonus_modifier == nil then
	lua_attribute_bonus_modifier = class({})
end

function lua_attribute_bonus_modifier:DeclareFunctions()
	local funcs = {
MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
	return funcs
end

function lua_attribute_bonus_modifier:OnCreated()
	if IsServer() then
		self.Primary = self:GetParent():GetPrimaryAttribute() 
	end
end


function lua_attribute_bonus_modifier:IsHidden()
	return true
end

function lua_attribute_bonus_modifier:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function lua_attribute_bonus_modifier:GetModifierBonusStats_Strength()
	return self:GetModifierBonusStats_All(0, self:GetParent():GetStrengthGain())
end
function lua_attribute_bonus_modifier:GetModifierBonusStats_Agility()
	return self:GetModifierBonusStats_All(1, self:GetParent():GetAgilityGain())
end
function lua_attribute_bonus_modifier:GetModifierBonusStats_Intellect()
	return self:GetModifierBonusStats_All(2, self:GetParent():GetIntellectGain())
end

function lua_attribute_bonus_modifier:GetModifierBonusStats_All(nType, nBonus)
	local hAbility = self:GetAbility()
	local nLevel = hAbility:GetLevel()
	if self.Primary == nType then nLevel = nLevel*1.4 end
	if self.Primary == nType then 
		return ((hAbility:GetSpecialValueFor( "attribute_bonus_per_level" ) + nBonus + (nBonus*nBonus*0.01)) * nLevel*(nLevel*0.1)-(nLevel))*1.3 + nLevel + 2^((nLevel*0.85)/5)
	else
		return ((hAbility:GetSpecialValueFor( "attribute_bonus_per_level" ) + nBonus + (nBonus*nBonus*0.01)) * nLevel*(nLevel*0.1)-(nLevel))*1.3 + nLevel + 2^(nLevel/5)
	end
	--
	
end