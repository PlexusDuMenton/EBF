require("libraries/utility")

function SelfDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local selfDamagePct = ability:GetSpecialValueFor("self_damage")/100
	ability.sacrifice = selfDamagePct*caster:GetHealth()
	caster:SetHealth(caster:GetHealth()-ability.sacrifice)
	local selfhurt = ParticleManager:CreateParticle("particles/necrophos_plague.vpcf", PATTACH_ABSORIGIN  , keys.caster)
    ParticleManager:SetParticleControl(selfhurt, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(selfhurt, 3, caster:GetAbsOrigin())
end

function AllyHeal(keys)
	local ability = keys.ability
	local target = keys.target
	
	local tickrate = ability:GetSpecialValueFor("tick_rate")
	local duration = ability:GetSpecialValueFor("duration")
	local healpct = ability:GetLevelSpecialValueFor("heal_per_health", -1)/100
	local base_heal = ability:GetLevelSpecialValueFor("base_heal", -1)
	local healtick = (ability.sacrifice*healpct + base_heal)/(duration/tickrate)
	target:Heal(healtick, caster)
	target:Purge(false, true, false, true, true)
	
	if target.selfhurt then ParticleManager:DestroyParticle(target.selfhurt,true) end
	target.selfhurt = ParticleManager:CreateParticle("particles/units/heroes/hero_necrolyte/necrolyte_scythe_mist.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(target.selfhurt, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(target.selfhurt, 2, target:GetAbsOrigin())
	
end

function EnemyDamage(keys)
	local ability = keys.ability
	local target = keys.target
	
	local tickrate = ability:GetSpecialValueFor("tick_rate")
	local duration = ability:GetSpecialValueFor("duration")
	local damagepct = ability:GetLevelSpecialValueFor("damage_per_health", -1)/100
	local base_damage = ability:GetLevelSpecialValueFor("base_damage", -1)
	local damagetick = (ability.sacrifice*damagepct+ base_damage)/(get_aether_multiplier(keys.caster)*(duration/tickrate)) 
	local damageType = ability:GetAbilityDamageType()
	if keys.caster:HasScepter() then damageType = DAMAGE_TYPE_PURE end
	ApplyDamage({victim = target, attacker = keys.caster, damage = damagetick, damage_type = damageType, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS ,ability = ability})
	
	if target.selfhurt then ParticleManager:DestroyParticle(target.selfhurt,true) end
	target.selfhurt = ParticleManager:CreateParticle("particles/units/heroes/hero_necrolyte/necrolyte_scythe_mist.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(target.selfhurt, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(target.selfhurt, 2, target:GetAbsOrigin())
end