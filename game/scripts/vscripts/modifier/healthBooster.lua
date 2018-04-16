healthBooster = class({})

function healthBooster:OnCreated(keys)
end

function healthBooster:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE --+ MODIFIER_ATTRIBUTE_MULTIPLE
end


function healthBooster:OnCreated()
  if IsServer() then
    self.Primary = self:GetParent():GetPrimaryAttribute() 
  end
end

function healthBooster:DeclareFunctions()
  local funcs = {
   MODIFIER_PROPERTY_HEALTH_BONUS
  }
  return funcs
end


function healthBooster:GetModifierHealthBonus()
  
  if (self:GetAbility() == nil) then
    self:GetParent():RemoveModifierByName(self:GetName())
    return 0
  end
  local HpPerStr=self:GetAbility():GetLevelSpecialValueFor("health_per_str",0)

  return HpPerStr*self:GetParent():GetStrength()
end

function healthBooster:IsHidden()
  return true 
end

function healthBooster:IsDebuff()
  return false
end

function healthBooster:IsPurgable()
  return false
end

function healthBooster:CheckState()
  local state = {
  }

  return state
end
