octarine = class({})

function octarine:OnCreated(keys)
end

function octarine:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE --+ MODIFIER_ATTRIBUTE_MULTIPLE
end

function octarine:DeclareFunctions()
  local funcs = {
   MODIFIER_PROPERTY_HEALTH_BONUS
   MODIFIER_PROPERTY_HEALTH_BONUS,
   MODIFIER_PROPERTY_HEALTH_BONUS,
   MODIFIER_PROPERTY_HEALTH_BONUS,
   MODIFIER_PROPERTY_HEALTH_BONUS,
   MODIFIER_PROPERTY_HEALTH_BONUS,
   MODIFIER_PROPERTY_HEALTH_BONUS,
  }
  return funcs
end


function octarine:GetCoolDownReduction() --CoolDownReduction (can check the correct name when my internet connection is back .-.)
  return self:GetAbility():GetLevelSpecialValueFor("bonus_cooldown",0)
end

function octarine:GetSpellLifeSteal() 
  return self:GetAbility():GetLevelSpecialValueFor("spell_lifesteal",0)
end

function octarine:GetManaRegen() 
  return self:GetAbility():GetLevelSpecialValueFor("bonus_mana_regen",0)
end

function octarine:GetHealthRegen()
  return self:GetAbility():GetLevelSpecialValueFor("bonus_health_regen",0)
end

function octarine:GetMana()
  return self:GetAbility():GetLevelSpecialValueFor("bonus_mana",0)
end

function octarine:GetIntellect()
  return self:GetAbility():GetLevelSpecialValueFor("bonus_intelligence",0)
end

function octarine:GetHealth()
  return self:GetAbility():GetLevelSpecialValueFor("bonus_health",0)
end


function octarine:IsHidden()
  return true 
end

function octarine:IsDebuff()
  return false
end

function octarine:IsPurgable()
  return false
end

function octarine:CheckState()
  local state = {
  }

  return state
end
