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
		local parent = self:GetAbility()
		if self:GetAbility():GetLevel() == 0 then
			parent.basestr = self:GetParent():GetBaseStrength()
			parent.baseagi = self:GetParent():GetBaseAgility()
			parent.baseint = self:GetParent():GetBaseIntellect()
		end
		local strlvl = self:GetParent():GetLevel() * self:GetParent():GetStrengthGain()
		local agilvl = self:GetParent():GetLevel() * self:GetParent():GetAgilityGain()
		local intlvl = self:GetParent():GetLevel() * self:GetParent():GetIntellectGain()
		self.Primary = self:GetParent():GetPrimaryAttribute()
		local strength = self:GetModifierBonusStats_All(0, self:GetParent():GetStrengthGain())
		local agility = self:GetModifierBonusStats_All(1, self:GetParent():GetAgilityGain())
		local intellect = self:GetModifierBonusStats_All(2, self:GetParent():GetIntellectGain())
		self:GetParent():SetBaseStrength(parent.basestr + strlvl + strength)
		self:GetParent():SetBaseAgility(parent.baseagi + agilvl + agility)
		self:GetParent():SetBaseIntellect(parent.baseint + intlvl + intellect)
	end
end


function lua_attribute_bonus_modifier:IsHidden()
	return true
end

function lua_attribute_bonus_modifier:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function lua_attribute_bonus_modifier:AllowIllusionDuplicate()
	return true
end

function lua_attribute_bonus_modifier:GetModifierBonusStats_All(nType, nBonus)
	local hAbility = self:GetAbility()
	local nLevel = hAbility:GetLevel()
	if self.Primary == nType then nLevel = nLevel*1.4 end
	if self.Primary == nType then 
		return ((hAbility:GetSpecialValueFor( "attribute_bonus_per_level" ) + nBonus + (nBonus*nBonus)) * nLevel*(nLevel*0.1)-(nLevel))*1.3 + nLevel + 2^((nLevel*0.85)/5)
	else
		return ((hAbility:GetSpecialValueFor( "attribute_bonus_per_level" ) + nBonus + (nBonus*nBonus*0.1)) * nLevel*(nLevel*0.1)-(nLevel))*1.3 + nLevel + 2^(nLevel/5)
	end
	--
	
end