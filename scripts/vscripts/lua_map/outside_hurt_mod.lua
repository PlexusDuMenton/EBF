if outside_map_ability_modifier == nil then
    outside_map_ability_modifier = class({})
end

function outside_map_ability_modifier:OnCreated( kv )  
    if IsServer() then
        self:StartIntervalThink( 0.2 )
    end
end

function outside_map_ability_modifier:IsHidden() return false end
function outside_map_ability_modifier:IsDebuff() return true end

function outside_map_ability_modifier:GetTexture()
    return "lava"
end

function outside_map_ability_modifier:OnIntervalThink()
    if IsServer() then
        if self:GetParent():IsAlive() then
            local hAttacker = self:GetParent()
            local damage = hAttacker:GetMaxHealth()*0.02
            local damageTable = {
                victim = self:GetParent(),
                attacker = hAttacker,
                damage = damage,
                damage_type = DAMAGE_TYPE_PURE,
            }
            ParticleManager:CreateParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_red_flames01.vpcf", PATTACH_ABSORIGIN , self:GetParent()) 

            ApplyDamage(damageTable)
        end
    end
end