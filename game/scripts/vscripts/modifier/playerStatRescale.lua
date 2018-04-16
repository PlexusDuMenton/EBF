playerStatRescale = class({})

function playerStatRescale:OnCreated(keys)
end

function playerStatRescale:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE --+ MODIFIER_ATTRIBUTE_MULTIPLE
end


function playerStatRescale:OnCreated()
  if IsServer() then
    self.Primary = self:GetParent():GetPrimaryAttribute() 
  end
end

function playerStatRescale:DeclareFunctions()
  local funcs = {
   MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
  MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
  MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
  }
  return funcs
end


function playerStatRescale:GetModifierBonusStats_Strength()
  return self:GetModifierBonusStats_All(0, self:GetParent():GetStrengthGain())
end
function playerStatRescale:GetModifierBonusStats_Agility()
  return self:GetModifierBonusStats_All(1, self:GetParent():GetAgilityGain())
end
function playerStatRescale:GetModifierBonusStats_Intellect()
  return self:GetModifierBonusStats_All(2, self:GetParent():GetIntellectGain())
end


function playerStatRescale:GetModifierBonusStats_All(nType, nBonus)
  local nLevel = self:GetParent():GetLevel()
  if self.Primary == nType then 
    return ((nBonus * (nLevel*0.5)^2 )* 1.1)
  else
    return nBonus * (nLevel*0.35)^1.9
  end
end


function playerStatRescale:IsHidden()
  return true --change that to true when finished debuging
end

function playerStatRescale:IsDebuff()
  return false
end

function playerStatRescale:IsPurgable()
  return false
end

function playerStatRescale:CheckState()
  local state = {
  }

  return state
end
