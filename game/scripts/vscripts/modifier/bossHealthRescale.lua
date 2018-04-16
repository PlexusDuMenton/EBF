bossHealthRescale = class({})

function bossHealthRescale:OnCreated(keys)
end

function bossHealthRescale:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE --+ MODIFIER_ATTRIBUTE_MULTIPLE
end

function bossHealthRescale:DeclareFunctions()
  local funcs = {
   MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
  }
  return funcs
end

function bossHealthRescale:OnCreated()
  if IsServer() then
    self:GetParent():SetMaxHealth(200000)
  end
end


function bossHealthRescale:GetModifierIncomingDamage_Percentage(event)
	if IsServer() then


		local EHPMult = self:GetParent().EHP_MULT
    local damagemult = (1-(1/EHPMult))*100
		return -damagemult
	end
end

function bossHealthRescale:IsHidden()
  return false --change that to true when finished debuging
end

function bossHealthRescale:IsDebuff()
  return false
end

function bossHealthRescale:IsPurgable()
  return false
end

function bossHealthRescale:CheckState()
  local state = {
  }

  return state
end
