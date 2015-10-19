function projectile_hit(keys)
	local lastskill = keys.caster.last_used_skill

	if lastskill == "fire_spear" then
		local target = keys.target
	    local caster = keys.caster
	    local fire = caster.invocation_power_fire
	    local damage_Hit = caster:GetLevel()*fire^2*50
	    local damageTableHit = {victim = target,
	                        attacker = caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)
	    keys.ability:ApplyDataDrivenModifier(caster, target, "fire_dot_display", {duration = 5})
        keys.ability:ApplyDataDrivenModifier(caster, target, "fire_dot", {duration = 5})
        target:SetModifierStackCount( "fire_dot", keys.ability, math.floor(fire*((keys.target:GetLevel()/2)^1.3)*25) )
	end

	if lastskill == "iceshard2" then
		local target = keys.target
	    local caster = keys.caster
	    local ice = caster.invocation_power_ice
	    local wind = caster.invocation_power_wind
	    local damage_Hit = caster:GetLevel()*wind^2*15
	    local damageTableHit = {victim = target,
	                        attacker = caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)
	    keys.ability:ApplyDataDrivenModifier(caster, target, "ice_slow_display", {duration = 5})
        keys.ability:ApplyDataDrivenModifier(caster, target, "ice_slow", {duration = 5})
        target:SetModifierStackCount( "ice_slow", keys.ability, math.floor(ice*5) )
	end

	if lastskill == "iceshard1" then
		local target = keys.target
	    local caster = keys.caster
	    local ice = caster.invocation_power_ice
	    local wind = caster.invocation_power_wind
	    local damage_Hit = caster:GetLevel()*wind^2*20
	    local damageTableHit = {victim = target,
	                        attacker = caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)
	    keys.ability:ApplyDataDrivenModifier(caster, target, "ice_slow_display", {duration = 5})
        keys.ability:ApplyDataDrivenModifier(caster, target, "ice_slow", {duration = 5})
        target:SetModifierStackCount( "ice_slow", keys.ability, math.floor(ice*5) )
	end

	if lastskill == "multiple_fire_spear" then
		local target = keys.target
	    local caster = keys.caster
	    local fire = caster.invocation_power_fire
	    local damage_Hit = caster:GetLevel()*fire^2*30
	    local damageTableHit = {victim = target,
	                        attacker = caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)
	    keys.ability:ApplyDataDrivenModifier(caster, target, "fire_dot_display", {duration = 5})
        keys.ability:ApplyDataDrivenModifier(caster, target, "fire_dot", {duration = 5})
        target:SetModifierStackCount( "fire_dot", keys.ability, math.floor(fire*((keys.target:GetLevel()/2)^1.3)*25) )
	end

	if lastskill == "explosive_fire_spear" then
		local target = keys.target
	    local caster = keys.caster
	    local fire = caster.invocation_power_fire
	    local damage_Hit = caster:GetLevel()*fire^2*100

	    local damageTableHit = {victim = target,
	                        attacker = caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)

	    local damage_AoE = caster:GetLevel()*fire^3*10
	    print (damage_Hit)
	    print (damage_AoE)
	    local radius = 500 + 25*fire
	    local nearbyUnits = FindUnitsInRadius(target:GetTeam(),
	                              target:GetAbsOrigin(),
	                              nil,
	                              radius,
	                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE,
	                              FIND_ANY_ORDER,
	                              false)
	    for _,unit in pairs(nearbyUnits) do
	        if unit ~= target then
	            local damageTableAoe = {victim = unit,
	                        attacker = caster,
	                        damage = damage_AoE,
	                        damage_type = DAMAGE_TYPE_PHYSICAL,
	                        }
	            ApplyDamage(damageTableAoe)
	            keys.ability:ApplyDataDrivenModifier(caster, unit, "fire_dot_display", {duration = 5})
            	keys.ability:ApplyDataDrivenModifier(caster, unit, "fire_dot", {duration = 5})
            	unit:SetModifierStackCount( "fire_dot", keys.ability, math.floor(fire*((keys.caster:GetLevel()/2)^1.3)*50) )
	        end
	    end

		ProjectileManager:DestroyLinearProjectile(keys.caster.projectile_table[1])
		fire_spear_explosion_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_calldown_explosion_second.vpcf", PATTACH_OVERHEAD_FOLLOW , target)
		target:EmitSound("Hero_Techies.Suicide")
		ParticleManager:SetParticleControl(fire_spear_explosion_effect, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(fire_spear_explosion_effect, 3, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(fire_spear_explosion_effect, 5, target:GetAbsOrigin())
	end

end