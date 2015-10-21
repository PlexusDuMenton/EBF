function projectile_hit(keys)
	local lastskill = keys.caster.last_used_skill

	if lastskill == "arcana_laser" then
		local target = keys.target
	    local caster = keys.caster
	    local damage_Hit = keys.caster:GetAverageTrueAttackDamage()*5

	    local damageTableHit = {victim = target,
	                        attacker = caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_PURE,
	                        }
	    ApplyDamage(damageTableHit)
	end

	if lastskill == "Heavy_Ice_Projectile" then
		local target = keys.target
	    local caster = keys.caster
	    local wind = caster.invocation_power_wind
	    local ice = caster.invocation_power_ice
	    local damage_Hit = keys.caster:GetLevel()*(ice+wind)^4*2

	    local damageTableHit = {victim = target,
	                        attacker = caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)

	    keys.ability:ApplyDataDrivenModifier(keys.caster, target, "ice_freeze_display", {duration = (ice/5)})
                keys.ability:ApplyDataDrivenModifier(keys.caster, target, "ice_freeze", {duration = (ice/5)})
                local ice_freeze_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf", PATTACH_ABSORIGIN  , target)
                ParticleManager:SetParticleControl(ice_freeze_effect, 0, target:GetAbsOrigin())
                ParticleManager:SetParticleControl(ice_freeze_effect, 1, target:GetAbsOrigin())
                Timers:CreateTimer((ice/5),function()
        	ParticleManager:DestroyParticle(ice_freeze_effect, false)
        end)
	end

	if lastskill == "IceFlame_Ball" then
		local target = keys.target
	    local caster = keys.caster
	    local fire = caster.invocation_power_fire
	    local ice = caster.invocation_power_ice
	    local damage_Hit = keys.caster:GetLevel()*(ice+fire)^3*20

	    local damageTableHit = {victim = target,
	                        attacker = caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)

	    local damage_AoE = caster:GetLevel()*fire^4*2 + ice^4 + (ice+fire)*2000
	    local radius = 500
	    local nearbyUnits = FindUnitsInRadius(target:GetTeam(),
	                              target:GetAbsOrigin(),
	                              nil,
	                              500,
	                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE,
	                              FIND_ANY_ORDER,
	                              false)
	    for _,unit in pairs(nearbyUnits) do
	            local damageTableAoe = {victim = unit,
	                        attacker = caster,
	                        damage = damage_AoE,
	                        damage_type = DAMAGE_TYPE_PHYSICAL,
	                        }
	            ApplyDamage(damageTableAoe)
            	Fire_Dot(caster, unit,math.floor((fire)^2*((keys.caster:GetLevel()/2)^1.5)*25))
            	keys.ability:ApplyDataDrivenModifier(keys.caster, unit, "iceflame_display", {duration = 5})
                keys.ability:ApplyDataDrivenModifier(keys.caster, unit, "slow_modifier", {duration = 5})
                unit:SetModifierStackCount( "slow_modifier", keys.ability, math.floor(ice*(20) ) )

                ice_flame_debuff_effect = ParticleManager:CreateParticle("particles/ice_flame_debuff.vpcf", PATTACH_ABSORIGIN , unit)
                ParticleManager:SetParticleControl(ice_flame_debuff_effect, 0, unit:GetAbsOrigin())
                ParticleManager:SetParticleControl(ice_flame_debuff_effect, 1, unit:GetAbsOrigin())

                Timers:CreateTimer(5,function()
			            ParticleManager:DestroyParticle( ice_flame_debuff_effect, false)
			    end)
	    end

		ProjectileManager:DestroyLinearProjectile(keys.caster.projectile_table[1])
		fire_spear_explosion_effect = ParticleManager:CreateParticle("particles/ice_ball_explosion.vpcf", PATTACH_ABSORIGIN , target)
		target:EmitSound("Hero_Techies.Suicide")
		ParticleManager:SetParticleControl(fire_spear_explosion_effect, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(fire_spear_explosion_effect, 5, target:GetAbsOrigin())
	end

	if lastskill == "fire_ball" then
		local target = keys.target
	    local caster = keys.caster
	    local fire = caster.invocation_power_fire
	    local wind = caster.invocation_power_wind
	    local damage_Hit = keys.caster:GetLevel()*fire^3*20

	    local damageTableHit = {victim = target,
	                        attacker = caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)

	    local damage_AoE = caster:GetLevel()*fire^4*2 + (fire)*2000
	    local radius = 500
	    local nearbyUnits = FindUnitsInRadius(target:GetTeam(),
	                              target:GetAbsOrigin(),
	                              nil,
	                              500,
	                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE,
	                              FIND_ANY_ORDER,
	                              false)
	    for _,unit in pairs(nearbyUnits) do
	            local damageTableAoe = {victim = unit,
	                        attacker = caster,
	                        damage = damage_AoE,
	                        damage_type = DAMAGE_TYPE_PHYSICAL,
	                        }
	            ApplyDamage(damageTableAoe)
	            keys.ability:ApplyDataDrivenModifier(caster, unit, "fire_dot_display", {duration = 5+1})
            	Fire_Dot(caster, unit,math.floor((fire/3)^2*((keys.caster:GetLevel()/2)^1.5)*25))

            	fire_debuff_effect = ParticleManager:CreateParticle("particles/fire_debuff.vpcf", PATTACH_ABSORIGIN , unit)
                ParticleManager:SetParticleControl(fire_debuff_effect, 0, unit:GetAbsOrigin())
                ParticleManager:SetParticleControl(fire_debuff_effect, 1, unit:GetAbsOrigin())

                Timers:CreateTimer(5,function()
			            ParticleManager:DestroyParticle( fire_debuff_effect, false)
			    end)
	    end

		ProjectileManager:DestroyLinearProjectile(keys.caster.projectile_table[1])
		fire_spear_explosion_effect = ParticleManager:CreateParticle("particles/fire_ball_explosion.vpcf", PATTACH_ABSORIGIN , target)
		target:EmitSound("Hero_Techies.Suicide")
		ParticleManager:SetParticleControl(fire_spear_explosion_effect, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(fire_spear_explosion_effect, 5, target:GetAbsOrigin())
	end

	if lastskill == "steam_trail" or lastskill == "steam_tempest" then

		local fire = keys.caster.invocation_power_fire
		local ice = keys.caster.invocation_power_ice
		local damage_Hit = keys.caster:GetLevel()*(ice^3*10 + fire^3*15)*1.5 + (ice+fire)*200
		keys.ability:ApplyDataDrivenModifier(caster, target, "fire_dot_display", {duration = 6})
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "slow_modifier_display", {duration = 6})
        keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "slow_modifier", {duration = 6})
        keys.target:SetModifierStackCount( "slow_modifier", keys.ability, math.floor(ice*3) )

        fire_debuff_effect = ParticleManager:CreateParticle("particles/fire_debuff.vpcf", PATTACH_ABSORIGIN , keys.target)
                ParticleManager:SetParticleControl(fire_debuff_effect, 0, keys.target:GetAbsOrigin())
                ParticleManager:SetParticleControl(fire_debuff_effect, 1, keys.target:GetAbsOrigin())

                Timers:CreateTimer(5,function()
			            ParticleManager:DestroyParticle( fire_debuff_effect, false)
			    end)

        

       	Fire_Dot(keys.caster, keys.target,math.floor((fire/3)^2*((keys.caster:GetLevel()/2)^1.5)*10),5+1)
	    local damageTableHit = {victim = keys.target,
	                        attacker = keys.caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)
		keys.duration = 0.2
		keys.distance = 40
		keys.range = (ice + fire)*200 +100
		keys.height = 0
		ApplyKnockback(keys)
	end

	if lastskill == "water_stream" or lastskill == "water_tempest" then

		local fire = keys.caster.invocation_power_fire
		local ice = keys.caster.invocation_power_ice
		local damage_Hit = keys.caster:GetLevel()*(ice^3 + (fire)^4)*10 + (ice+fire)*1500
		print (damage_Hit)
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "slow_modifier_display", {duration = 11})
        keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "slow_modifier", {duration = 11})
        keys.target:SetModifierStackCount( "slow_modifier", keys.ability, math.floor(ice*5) )
	    local damageTableHit = {victim = keys.target,
	                        attacker = keys.caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)
		keys.duration = 1
		keys.distance = 120
		keys.range = (ice + fire)*200 +100
		keys.height = 0
		ApplyKnockback(keys)
	end

	if lastskill == "wind_stream" then
		local wind = keys.caster.invocation_power_wind
		local damage_Hit = keys.caster:GetLevel()*wind^3*20 + (wind)*500
	    local damageTableHit = {victim = keys.target,
	                        attacker = keys.caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)
		keys.duration = (wind/6)
		keys.distance = (wind*50)
		keys.range = (wind*200)
		keys.height = 0
		ApplyKnockback(keys)
	end

	if lastskill == "Blizzard" then
		local target = keys.target
		local caster = keys.caster
		local wind = keys.caster.invocation_power_wind
		local ice = keys.caster.invocation_power_ice
		local damage_Hit = keys.caster:GetLevel()*(ice+wind)^4 * 0.5 + (ice+wind)*500
		keys.ability:ApplyDataDrivenModifier(caster, target, "slow_modifier_display", {duration = 5+(wind/4)})
        keys.ability:ApplyDataDrivenModifier(caster, target, "slow_modifier", {duration = 5+(wind/4)})
        target:SetModifierStackCount( "slow_modifier", keys.ability, math.floor(ice*5) )

       	keys.ability:ApplyDataDrivenModifier(keys.caster, target, "ice_freeze_display", {duration = (ice/5)+(wind/4)})
                keys.ability:ApplyDataDrivenModifier(keys.caster, target, "ice_freeze", {duration = (ice/5)+(wind/4)})
                local ice_freeze_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf", PATTACH_ABSORIGIN  , target)
                ParticleManager:SetParticleControl(ice_freeze_effect, 0, target:GetAbsOrigin())
                ParticleManager:SetParticleControl(ice_freeze_effect, 1, target:GetAbsOrigin())
                Timers:CreateTimer((ice/5)+(wind/4),function()
                    ParticleManager:DestroyParticle(ice_freeze_effect, false)
                end)

	    local damageTableHit = {victim = keys.target,
	                        attacker = keys.caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)
		keys.distance = 0
		keys.duration = (wind/4)
		keys.range = (wind*500)
		keys.height = 280
		ApplyKnockback(keys)
	end

	if lastskill == "Ice_Tornado" then

		local target = keys.target
		local caster = keys.caster
		local wind = keys.caster.invocation_power_wind
		local ice = keys.caster.invocation_power_ice
		local damage_Hit = keys.caster:GetLevel()*(ice+wind)^4 *0.5 + (ice+wind)*1000
		keys.ability:ApplyDataDrivenModifier(caster, target, "slow_modifier_display", {duration = 5+(wind/4)})
        keys.ability:ApplyDataDrivenModifier(caster, target, "slow_modifier", {duration = 5+(wind/4)})
        target:SetModifierStackCount( "slow_modifier", keys.ability, math.floor(ice*5) )

        keys.ability:ApplyDataDrivenModifier(keys.caster, target, "ice_freeze_display", {duration = (ice/5)+(wind/4)})
                keys.ability:ApplyDataDrivenModifier(keys.caster, target, "ice_freeze", {duration = (ice/5)+(wind/4)})
                local ice_freeze_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf", PATTACH_ABSORIGIN  , target)
                ParticleManager:SetParticleControl(ice_freeze_effect, 0, target:GetAbsOrigin())
                ParticleManager:SetParticleControl(ice_freeze_effect, 1, target:GetAbsOrigin())
                Timers:CreateTimer((ice/5)+(wind/4),function()
                    ParticleManager:DestroyParticle(ice_freeze_effect, false)
                end)



	    local damageTableHit = {victim = keys.target,
	                        attacker = keys.caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)
		keys.duration = (wind/4)
		keys.distance = 0
		keys.range = (wind*500)
		keys.height = 280
		ApplyKnockback(keys)
	end

	if lastskill == "Fire_Tempest" then
		local target = keys.target
		local caster = keys.caster
		local wind = keys.caster.invocation_power_wind
		local fire = keys.caster.invocation_power_fire
		local damage_Hit = keys.caster:GetLevel()*(fire+wind)^4*2 + (fire+wind)*1000
		keys.duration = (wind/4)
		keys.ability:ApplyDataDrivenModifier(caster, target, "fire_dot_display", {duration = 5+(wind/4)})

		fire_debuff_effect = ParticleManager:CreateParticle("particles/fire_debuff.vpcf", PATTACH_ABSORIGIN , keys.target)
                ParticleManager:SetParticleControl(fire_debuff_effect, 0, keys.target:GetAbsOrigin())
                ParticleManager:SetParticleControl(fire_debuff_effect, 1, keys.target:GetAbsOrigin())

                Timers:CreateTimer(5+(wind/4),function()
			            ParticleManager:DestroyParticle( fire_debuff_effect, false)
			    end)

       	Fire_Dot(keys.caster, keys.target,math.floor((fire/3)^2*((keys.caster:GetLevel()/2)^1.5)*25),5+(wind/4))
	    local damageTableHit = {victim = keys.target,
	                        attacker = keys.caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)
	    keys.duration = (wind/4)
		keys.distance = 0
		keys.range = (wind*500)
		keys.height = 280
		ApplyKnockback(keys)
	end

	if lastskill == "Fire_Tornado" then

		local target = keys.target
		local caster = keys.caster
		local wind = keys.caster.invocation_power_wind
		local fire = keys.caster.invocation_power_fire
		local damage_Hit = keys.caster:GetLevel()*(fire+wind)^4*15 + (fire+wind)*1000 
		keys.ability:ApplyDataDrivenModifier(caster, target, "fire_dot_display", {duration = 5+(wind/4)})
        Fire_Dot(keys.caster, keys.target,math.floor((fire)^2*((keys.caster:GetLevel()/2)^1.5)*40),5+(wind/4))

        fire_debuff_effect = ParticleManager:CreateParticle("particles/fire_debuff.vpcf", PATTACH_ABSORIGIN , keys.target)
                ParticleManager:SetParticleControl(fire_debuff_effect, 0, keys.target:GetAbsOrigin())
                ParticleManager:SetParticleControl(fire_debuff_effect, 1, keys.target:GetAbsOrigin())

                Timers:CreateTimer(5+(wind/4),function()
			            ParticleManager:DestroyParticle( fire_debuff_effect, false)
			    end)

	    local damageTableHit = {victim = keys.target,
	                        attacker = keys.caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)
		keys.duration = (wind/4)
		keys.distance = 0
		keys.range = (wind*500)
		keys.height = 280
		ApplyKnockback(keys)
	end

	if lastskill == "Turnado" then

		local wind = keys.caster.invocation_power_wind
		local damage_Hit = keys.caster:GetLevel()*wind^3*15 + (wind)*1000
	    local damageTableHit = {victim = keys.target,
	                        attacker = keys.caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)
		keys.duration = (wind/6)
		keys.distance = 0
		keys.range = (wind*200)
		keys.height = 280
		ApplyKnockback(keys)
	end

	if lastskill == "Tempest" then

		local wind = keys.caster.invocation_power_wind
		local damage_Hit = keys.caster:GetLevel()*wind^3*15 + (wind)*500
	    local damageTableHit = {victim = keys.target,
	                        attacker = keys.caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)
		keys.duration = (wind/6)
		keys.distance = 0
		keys.range = (wind*200)
		keys.height = 280
		ApplyKnockback(keys)
	end

	if lastskill == "fire_spear" then
		local target = keys.target
	    local caster = keys.caster
	    local fire = caster.invocation_power_fire
	    local damage_Hit = keys.caster:GetLevel()*fire^3*10 + (fire)*500
	    print (damage_Hit)
	    local damageTableHit = {victim = target,
	                        attacker = caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)
	    keys.ability:ApplyDataDrivenModifier(caster, target, "fire_dot_display", {duration = 5})
	    fire_debuff_effect = ParticleManager:CreateParticle("particles/fire_debuff.vpcf", PATTACH_ABSORIGIN , keys.target)
                ParticleManager:SetParticleControl(fire_debuff_effect, 0, keys.target:GetAbsOrigin())
                ParticleManager:SetParticleControl(fire_debuff_effect, 1, keys.target:GetAbsOrigin())

                Timers:CreateTimer(5,function()
			            ParticleManager:DestroyParticle( fire_debuff_effect, false)
			    end)
        Fire_Dot(keys.caster, keys.target,math.floor((fire/3)^2*((keys.caster:GetLevel()/2)^1.5)*25))
	end

	if lastskill == "iceshard2" then
		local target = keys.target
	    local caster = keys.caster
	    local ice = caster.invocation_power_ice
	    local wind = caster.invocation_power_wind
	    local damage_Hit = keys.caster:GetLevel()*wind^3*15 + (ice+wind)*500
	    local damageTableHit = {victim = target,
	                        attacker = caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)
	    keys.ability:ApplyDataDrivenModifier(caster, target, "slow_modifier_display", {duration = 5})
        keys.ability:ApplyDataDrivenModifier(caster, target, "slow_modifier", {duration = 5})
        target:SetModifierStackCount( "slow_modifier", keys.ability, math.floor(ice*5) )
        local ice_freeze_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf", PATTACH_ABSORIGIN  , target)
        ParticleManager:SetParticleControl(ice_freeze_effect, 0, keys.target:GetAbsOrigin())
    	ParticleManager:SetParticleControl(ice_freeze_effect, 1, keys.target:GetAbsOrigin())
                Timers:CreateTimer((ice/5),function()
                    ParticleManager:DestroyParticle(ice_freeze_effect, false)
                end)
	end

	if lastskill == "iceshard1" then
		local target = keys.target
	    local caster = keys.caster
	    local ice = caster.invocation_power_ice
	    local wind = caster.invocation_power_wind
	    local damage_Hit = keys.caster:GetLevel()*wind^3*30 + (ice+wind)*1000
	    local damageTableHit = {victim = target,
	                        attacker = caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)
	    keys.ability:ApplyDataDrivenModifier(caster, target, "slow_modifier_display", {duration = 5})
        keys.ability:ApplyDataDrivenModifier(caster, target, "slow_modifier", {duration = 5})
        target:SetModifierStackCount( "slow_modifier", keys.ability, math.floor(ice*5) )
        local ice_freeze_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf", PATTACH_ABSORIGIN  , target)
        ParticleManager:SetParticleControl(ice_freeze_effect, 0, keys.target:GetAbsOrigin())
    	ParticleManager:SetParticleControl(ice_freeze_effect, 1, keys.target:GetAbsOrigin())
                Timers:CreateTimer((ice/5),function()
                    ParticleManager:DestroyParticle(ice_freeze_effect, false)
                end)
	end

	if lastskill == "multiple_fire_spear" then
		local target = keys.target
	    local caster = keys.caster
	    local fire = caster.invocation_power_fire
	    local damage_Hit = keys.caster:GetLevel()*fire^3*10 + (fire)*250
	    local damageTableHit = {victim = target,
	                        attacker = caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)
	    keys.ability:ApplyDataDrivenModifier(caster, target, "fire_dot_display", {duration = 5})
	    fire_debuff_effect = ParticleManager:CreateParticle("particles/fire_debuff.vpcf", PATTACH_ABSORIGIN , keys.target)
                ParticleManager:SetParticleControl(fire_debuff_effect, 0, keys.target:GetAbsOrigin())
                ParticleManager:SetParticleControl(fire_debuff_effect, 1, keys.target:GetAbsOrigin())

                Timers:CreateTimer(5,function()
			            ParticleManager:DestroyParticle( fire_debuff_effect, false)
			    end)
        Fire_Dot(keys.caster, keys.target,math.floor((fire/3)^2*((keys.caster:GetLevel()/2)^1.5)*25))
	end

	if lastskill == "explosive_fire_spear" then
		local target = keys.target
	    local caster = keys.caster
	    local fire = caster.invocation_power_fire
	    local damage_Hit = keys.caster:GetLevel()*fire^3*20 + (fire)*2000

	    local damageTableHit = {victim = target,
	                        attacker = caster,
	                        damage = damage_Hit,
	                        damage_type = DAMAGE_TYPE_MAGICAL,
	                        }
	    ApplyDamage(damageTableHit)

	    local damage_AoE = caster:GetLevel()*fire^4*2
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
	            local damageTableAoe = {victim = unit,
	                        attacker = caster,
	                        damage = damage_AoE,
	                        damage_type = DAMAGE_TYPE_PHYSICAL,
	                        }
	            ApplyDamage(damageTableAoe)
	            keys.ability:ApplyDataDrivenModifier(caster, unit, "fire_dot_display", {duration = 5})
            	keys.ability:ApplyDataDrivenModifier(caster, unit, "fire_dot", {duration = 5})
            	Fire_Dot(caster, unit,math.floor((fire/3)^2*((keys.caster:GetLevel()/2)^1.5)*25))

            	fire_debuff_effect = ParticleManager:CreateParticle("particles/fire_debuff.vpcf", PATTACH_ABSORIGIN , unit)
                ParticleManager:SetParticleControl(fire_debuff_effect, 0, unit:GetAbsOrigin())
                ParticleManager:SetParticleControl(fire_debuff_effect, 1, unit:GetAbsOrigin())

                Timers:CreateTimer(5,function()
			            ParticleManager:DestroyParticle( fire_debuff_effect, false)
			    end)
	    end

		ProjectileManager:DestroyLinearProjectile(keys.caster.projectile_table[1])
		fire_spear_explosion_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_calldown_explosion_second.vpcf", PATTACH_OVERHEAD_FOLLOW , target)
		target:EmitSound("Hero_Techies.Suicide")
		ParticleManager:SetParticleControl(fire_spear_explosion_effect, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(fire_spear_explosion_effect, 3, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(fire_spear_explosion_effect, 5, target:GetAbsOrigin())
	end

end

function Fire_Dot(caster,target,Damage,duration)
	if duration == nil then
		duration = 5
	end

	local damageTableDOT = {victim = target,
	                    attacker = caster,
	                    damage = Damage,
	                    damage_type = DAMAGE_TYPE_MAGICAL,
	                    }
	local begin_time = GameRules:GetGameTime()

	Timers:CreateTimer(1.00,function()
   			if GameRules:GetGameTime() <= begin_time+duration then
	   			ApplyDamage(damageTableDOT)
	   			return 1.00
	   		else
	   			return
	   		end
   		end)
end

function ApplyKnockback( keys )
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_knockback_wind", {duration = keys.duration})

    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    -- Position variables
    local target_origin = target:GetAbsOrigin()
    local target_initial_x = target_origin.x
    local target_initial_y = target_origin.y
    local target_initial_z = target_origin.z
    local position = Vector(target_initial_x, target_initial_y, target_initial_z)  --This is updated whenever the target has their position changed.
    
    local duration = keys.duration
    local begin_time = GameRules:GetGameTime()
   	if keys.distance > 0 then
   		local len = ( target:GetAbsOrigin() - caster:GetAbsOrigin() ):Length2D()
   		local vector = ( target:GetAbsOrigin() - caster:GetAbsOrigin() )/len
   		local travel_distance = vector * keys.distance
   		local number_of_frame = duration*(1/.03)
   		local travel_distance_per_frame = travel_distance/number_of_frame
   		Timers:CreateTimer(duration,function()
   			FindClearSpaceForUnit(target, position, true)
   		end)
   		print (travel_distance_per_frame)
   		Timers:CreateTimer(0.03 ,function()
   			if GameRules:GetGameTime() <= begin_time+duration then
	   			position = position+travel_distance_per_frame
	   			target:SetAbsOrigin(position)
	   			return 0.03
	   		else
	   			return
	   		end
   		end)

    elseif keys.height > 0 then
    	keys.target:EmitSound("Hero_Invoker.Tornado.Target")
   		local turnado_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_tornado_child.vpcf", PATTACH_ABSORIGIN , target)
		ParticleManager:SetParticleControl(turnado_effect, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(turnado_effect, 1, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(turnado_effect, 2, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(turnado_effect, 3, target:GetAbsOrigin())
		print (keys.duration)
		Timers:CreateTimer(keys.duration,function()
   			keys.target:StopSound("Hero_Invoker.Tornado.Target")
   			ParticleManager:DestroyParticle(turnado_effect, false)
   		end)
   		

	    local ground_position = GetGroundPosition(position, target)
	    local cyclone_initial_height = keys.height + ground_position.z
	    local cyclone_min_height = keys.height + ground_position.z + 10
	    local cyclone_max_height = keys.height + ground_position.z + 110
	    local tornado_start = GameRules:GetGameTime()

	    -- Height per time calculation
	    local time_to_reach_initial_height = duration / 10  --1/10th of the total cyclone duration will be spent ascending and descending to and from the initial height.
	    local initial_ascent_height_per_frame = ((cyclone_initial_height - position.z) / time_to_reach_initial_height) * .03  --This is the height to add every frame when the unit is first cycloned, and applies until the caster reaches their max height.
	    
	    local up_down_cycle_height_per_frame = initial_ascent_height_per_frame / 3  --This is the height to add or remove every frame while the caster is in up/down cycle mode.
	    if up_down_cycle_height_per_frame > 7.5 then  --Cap this value so the unit doesn't jerk up and down for short-duration cyclones.
	        up_down_cycle_height_per_frame = 7.5
	    end
	    
	    local final_descent_height_per_frame = nil  --This is calculated when the unit begins descending.

	    -- Time to go down
	    local time_to_stop_fly = duration - time_to_reach_initial_height

	    -- Loop up and down
	    local going_up = true

	    -- Loop every frame for the duration
	    Timers:CreateTimer(function()
	        local time_in_air = GameRules:GetGameTime() - tornado_start
	        
	        -- First send the target to the cyclone's initial height.
	        if position.z < cyclone_initial_height and time_in_air <= time_to_reach_initial_height then
	            --print("+",initial_ascent_height_per_frame,position.z)
	            position.z = position.z + initial_ascent_height_per_frame
	            target:SetAbsOrigin(position)
	            return 0.03

	        -- Go down until the target reaches the ground.
	        elseif time_in_air > time_to_stop_fly and time_in_air <= duration then
	            --Since the unit may be anywhere between the cyclone's min and max height values when they start descending to the ground,
	            --the descending height per frame must be calculated when that begins, so the unit will end up right on the ground when the duration is supposed to end.
	            if final_descent_height_per_frame == nil then
	                local descent_initial_height_above_ground = position.z - ground_position.z
	                --print("ground position: " .. GetGroundPosition(position, target).z)
	                --print("position.z : " .. position.z)
	                final_descent_height_per_frame = (descent_initial_height_above_ground / time_to_reach_initial_height) * .03
	            end
	            
	            --print("-",final_descent_height_per_frame,position.z)
	            position.z = position.z - final_descent_height_per_frame
	            target:SetAbsOrigin(position)
	            return 0.03

	        -- Do Up and down cycles
	        elseif time_in_air <= duration then
	            -- Up
	            if position.z < cyclone_max_height and going_up then 
	                --print("going up")
	                position.z = position.z + up_down_cycle_height_per_frame
	                target:SetAbsOrigin(position)
	                return 0.03

	            -- Down
	            elseif position.z >= cyclone_min_height then
	                going_up = false
	                --print("going down")
	                position.z = position.z - up_down_cycle_height_per_frame
	                target:SetAbsOrigin(position)
	                return 0.03

	            -- Go up again
	            else
	                --print("going up again")
	                going_up = true
	                return 0.03
	            end

	        -- End
	        else
	            --print(GetGroundPosition(target:GetAbsOrigin(), target))
	            --print("End TornadoHeight")
	        end
	    end)
	end
end
