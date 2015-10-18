--[[ ============================================================================================================
    Author: FrenchDeath
    Date: October 18th 2015
    Ellementalist combine his ellement and cas a spell based on the power of each ellement
================================================================================================================= ]]
function On_Spell_Start( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	caster.invocation_power_fire = 0
	caster.invocation_power_wind = 0
	caster.invocation_power_ice = 0
	local number_of_orb = table.getn(caster.invoked_orbs_particle_attach)

	local invoke_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_invoke.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)

	for i=1, number_of_orb, 1 do
		if keys.caster.invoked_orbs[i] ~= nil then
            local orb_name = keys.caster.invoked_orbs[i]:GetName()
            if orb_name == "invoker_wind_ellement" then
                local wind_ability = keys.caster:FindAbilityByName("invoker_wind_ellement")
                print (wind_ability:GetName())
                local wind_power = wind_ability:GetLevelSpecialValueFor("ellement_power", wind_ability:GetLevel() - 1)
                print (wind_power)
                caster.invocation_power_wind = wind_power + caster.invocation_power_wind 
            elseif orb_name == "invoker_fire_ellement" then
                local fire_ability = keys.caster:FindAbilityByName("invoker_fire_ellement")
                local fire_power = fire_ability:GetLevelSpecialValueFor("ellement_power", fire_ability:GetLevel() - 1)
                caster.invocation_power_fire = fire_power + caster.invocation_power_fire
            elseif orb_name == "invoker_ice_ellement" then
                local ice_ability = keys.caster:FindAbilityByName("invoker_ice_ellement")
                local ice_power = ice_ability:GetLevelSpecialValueFor("ellement_power", ice_ability:GetLevel() - 1)
                caster.invocation_power_ice = ice_power + caster.invocation_power_ice
            end
        end
	end
	print ("wind power : ".. caster.invocation_power_wind)
	print ("fire power : ".. caster.invocation_power_fire)
	print ("ice power : ".. caster.invocation_power_ice)
	local ice_color = Vector(0, 153, 204)
    local wind_color = Vector(204, 0, 153)
    local fire_color = Vector(255, 102, 0)
	ParticleManager:SetParticleControl(invoke_particle_effect, 2, ((ice_color * caster.invocation_power_ice) + (fire_color * caster.invocation_power_fire) + (wind_color * caster.invocation_power_wind)) / (caster.invocation_power_ice + caster.invocation_power_wind + caster.invocation_power_fire))
	local ice = caster.invocation_power_ice
    local wind = caster.invocation_power_wind
    local fire = caster.invocation_power_fire

    --Skill with Main ellement : Fire
    if fire >= ice + wind then --Very High Damage + DoT
		if fire >= 2.6 and fire <= 5 then
			--Fire spear
		elseif fire >= 5 and fire <= 10 then
			--multiple Fire spear
		elseif fire >= 10 
			--explosive Fire Spear (AOE :O)
		else
			--bonus damage aura (30 sec , bonus depend on character level and power of ellement)
		end

	--Skill with Main ellement : Wind
	elseif wind >= ice + fire then --medium/High damage + slow + knockback
		if wind >= 2.6 and wind <= 5 then
			--Simple wind , knockback and medium damage
		elseif wind >= 5 and wind <= 10 then
			--Turnado
		elseif wind >= 10 
			--Tempest (multiple turnado)
		else
			--bonus speed/attack speed aura (30 sec)
		end

	--Skill with Main ellement : Ice
	elseif ice >= wind + fire then --Low Damage , Slow/disable
		if ice >= 2.6 and ice <= 5 then
			--Ice Spike (front)
		elseif ice >= 5 and ice <= 10 then
			--Ice Spike Aoe 
		elseif ice >= 10 
			--Frost Spike AOE (Stun)
		else
			--Slow ennemy on attack
		end

    --Skill with Ice and Fire mix
	elseif ice + fire >= 2*wind then 
		if fire >= 1.5*ice then 
			if ice + fire >= 10 then --high Damage
				--Steam Tempest
			else
				--steam trail
			end
		elseif ice >= 1.5*fire then --Slow + DoT , medium damage
			if ice + fire >= 10 then
				--Explosive IceFlame
			else
				--IceFireBall
			end
		else 
			if ice + fire >= 10 then --Disable/slow , medium damage
				--Water Tempest
			else
				--Water Stream
			end
		end

    --Skill with Ice and Wind mix
	elseif ice + wind >= 2*fire then --Medium/Low damage ,High slow and disable
		if ice >= 1.5*wind then
			if ice + wind >= 10 then
				--Ice Meteor
			else 
				--iceball ability
			end
		if wind >= 1.5*ice then
			if ice + wind >= 10 then
				--BLizzard
			else
				--cold wind
			end
		else
			if ice + wind >= 10 then
				--iceshard lvl 2 (crystal maiden like)
			else 
				--iceshard lvl 1 
			end
		end

    --Skill with Wind and Fire mix
	elseif wind + fire >= 2* ice then --Very High Damage and DoT
		if fire >= 1.5*wind then
			if fire + wind >= 10 then
				--meteor
			else 
				--fireball
			end

		if wind >= 1.5*fire then
			if fire + wind >= 10 then
				--FireExplosion
			else
				--fire breathe
			end
		else 
			if fire + wind >= 10 then
				--Fire Tempest
			else
				--Fire turnado
			end
		end

    --Skill with both of 3 ellement
	else
		if fire + wind + ice >= 7.5 then
			--Global heal
		elseif fire + wind + ice >= 15 then
			--Arcana Laser (HUGE damage , slow ennemy , apply DOT , but set a high cooldown on combine skill :p)
		else
			--personal heal
		end
	end
end

