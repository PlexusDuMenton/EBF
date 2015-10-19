--[[ ============================================================================================================
    Author: FrenchDeath
    Date: October 18th 2015
    Ellementalist combine his ellement and cas a spell based on the power of each ellement
================================================================================================================= ]]
function On_Spell_Start( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	if keys.caster.invoked_orbs == nil then return end
	caster.last_used_skill = "none"
    caster.projectile_table = {}
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
	local ice_color = Vector(0, 153, 204)
    local wind_color = Vector(204, 0, 153)
    local fire_color = Vector(255, 102, 0)
	ParticleManager:SetParticleControl(invoke_particle_effect, 2, ((ice_color * caster.invocation_power_ice) + (fire_color * caster.invocation_power_fire) + (wind_color * caster.invocation_power_wind)) / (caster.invocation_power_ice + caster.invocation_power_wind + caster.invocation_power_fire))
	local ice = caster.invocation_power_ice
    local wind = caster.invocation_power_wind
    local fire = caster.invocation_power_fire
    print ("wind power : ".. wind)
	print ("fire power : ".. fire)
	print ("ice power : ".. ice)

    --Skill with Main ellement : Fire
    if fire > ice + wind then --Very High Damage + DoT
    	print ("fire")
		if fire > 2.51 and fire <= 5 then
			caster.last_used_skill = "fire_spear"
			projectile_fire_spear( keys )
		elseif fire > 5 and fire <= 10 then
            caster.last_used_skill = "multiple_fire_spear"
			projectile_multiple_fire_spear( keys , fire)
		elseif fire > 10 then
			caster.last_used_skill = "explosive_fire_spear"
            projectile_fire_spear( keys )
		else
			poweraura( keys , fire)
		end
	elseif wind > ice + fire then --medium/High damage + slow + knockback
		print ("wind")
		if wind >= 2.51 and wind <= 5 then
			--Simple wind , knockback and medium damage
		elseif wind >= 5 and wind <= 10 then
			--Turnado
		elseif wind > 10 then
			--Tempest (multiple turnado)
		else
			speedaura( keys , wind)
		end
	elseif ice > wind + fire then --Low Damage , Slow/disable
		print ("ice")
		if ice >= 2.51 and ice <= 5 then
			--Ice Spike (front)
		elseif ice > 5 and ice <= 10 then
			--Ice Spike Aoe 
		elseif ice > 10 then
			--Frost Spike AOE (Stun)
		else
			frosttouch( keys )
		end
	elseif ice + fire > 2*wind then 
		print ("ice + fire")
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
	elseif ice + wind > 2*fire then --Medium/Low damage ,High slow and disable
		print ("ice + wind")
		if ice >= 1.5*wind then
			if ice + wind >= 10 then
				--Ice Meteor
			else 
				--iceball ability
			end
		elseif wind >= 1.5*ice then
			if ice + wind >= 10 then
				--BLizzard
			else
				--cold wind
			end
		else
			if ice + wind >= 10 then
				caster.last_used_skill = "iceshard2"
				projectile_iceshard2(keys , ice, wind, fire)
			else 
				caster.last_used_skill = "iceshard1"
				projectile_iceshard1(keys , ice, wind, fire)
			end
		end
	elseif wind + fire > 2* ice then --Very High Damage and DoT
		print ("wind + fire")
		if fire >= 1.5*wind then
			if fire + wind >= 10 then
				--meteor
			else 
				--fireball
			end

		elseif wind >= 1.5*fire then
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
	else
		if fire + wind + ice >= 7.5 and fire + wind + ice < 15 then
			print ("glocal heal")
			global_heal( keys, fire, ice, wind)
		elseif fire + wind + ice >= 15 then
			print ("arcana_laser")
			
		else
			personal_heal( keys, fire, ice, wind)
		end
	end
end

function slow_modifier_caster_hit(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local ice = caster.invocation_power_ice
    ability:ApplyDataDrivenModifier(caster, target, "slow_modifier_display", {duration = 5})
    ability:ApplyDataDrivenModifier(caster, target, "slow_modifier", {duration = 5})
    target:SetModifierStackCount( "slow_modifier", ability, math.floor(ice*(20) ) )
end

function frosttouch( keys )
    local caster = keys.caster
    local ability = keys.ability
    ability:ApplyDataDrivenModifier(caster, caster, "slow_modifier_caster", {duration = 20})
end

function speedaura( keys , wind)
    local caster = keys.caster
    local ability = keys.ability
    for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
        if unit:GetTeam() == keys.caster:GetTeam() then
            ability:ApplyDataDrivenModifier(caster, unit, "speed_aura_display", {duration = 20})
            ability:ApplyDataDrivenModifier(caster, unit, "speed_aura", {duration = 20})
            unit:SetModifierStackCount( "speed_aura", ability, math.floor(wind*(75+keys.caster:GetLevel() ) ) )
        end
    end
end

function poweraura( keys , fire)
    local ability = keys.ability
    for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
        if unit:GetTeam() == keys.caster:GetTeam() then
            ability:ApplyDataDrivenModifier(keys.caster, unit, "power_aura_display", {duration = 20})
            ability:ApplyDataDrivenModifier(keys.caster, unit, "power_aura", {duration = 20})
            unit:SetModifierStackCount( "power_aura", ability, math.floor(fire*((keys.caster:GetLevel()/2)^1.3)*50) )
        end
    end
end
function ShowPopup( data )
    if not data then return end

    local target = data.Target or nil
    if not target then error( "ShowNumber without target" ) end
    local number = tonumber( data.Number or nil )
    local pfx = data.Type or "miss"
    local player = data.Player or nil
    local color = data.Color or Vector( 255, 255, 255 )
    local duration = tonumber( data.Duration or 1 )
    local presymbol = tonumber( data.PreSymbol or nil )
    local postsymbol = tonumber( data.PostSymbol or nil )

    local path = "particles/msg_fx/msg_" .. pfx .. ".vpcf"
    local particle = ParticleManager:CreateParticle(path, PATTACH_OVERHEAD_FOLLOW, target)
    if player ~= nil then
        local particle = ParticleManager:CreateParticleForPlayer( path, PATTACH_OVERHEAD_FOLLOW, target, player)
    end

    local digits = 0
    if number ~= nil then digits = #tostring( number ) end
    if presymbol ~= nil then digits = digits + 1 end
    if postsymbol ~= nil then digits = digits + 1 end

    ParticleManager:SetParticleControl( particle, 1, Vector( presymbol, number, postsymbol ) )
    ParticleManager:SetParticleControl( particle, 2, Vector( duration, digits, 0 ) )
    ParticleManager:SetParticleControl( particle, 3, color )
end

function personal_heal( keys, fire, ice, wind)
	local caster = keys.caster
	local percent = (fire + ice + wind)*0.1
	local heal = math.floor(caster:GetMaxHealth()*percent)
	caster:SetHealth(caster:GetHealth() + heal)
                        ShowPopup( {
	                        Target = keys.caster,
	                        PreSymbol = 8,
	                        PostSymbol = 2,
	                        Color = Vector( 0, 255, 33 ),
	                        Duration = 0.5,
	                        Number = heal,
	                        pfx = "heal",
	                        Player = PlayerResource:GetPlayer( caster:GetPlayerID() )
                        } )
end
function global_heal( keys, fire, ice, wind)
	local caster = keys.caster
	local percent = (fire + ice + wind)*0.1
	print (percent)
	for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
		if unit:GetTeam() == caster:GetTeam() then
			local heal = math.floor(unit:GetMaxHealth()*percent)
			unit:SetHealth(unit:GetHealth() + heal)
			 ShowPopup( {
	                        Target = keys.unit,
	                        PreSymbol = 8,
	                        PostSymbol = 2,
	                        Color = Vector( 0, 255, 33 ),
	                        Duration = 0.5,
	                        Number = heal,
	                        pfx = "heal",
	                        Player = PlayerResource:GetPlayer( unit:GetPlayerID() )
                        } )
		end
	end
end


function projectile_multiple_fire_spear( keys , fire)
    local ability = keys.ability
    local caster = keys.caster

    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/fire_spear.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = 5000,
        fStartRadius = 50,
        fEndRadius = 50,
        fExpireTime = GameRules:GetGameTime() + 5,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 600,
        vAcceleration = caster:GetForwardVector() * 200
    }
    local created_projectile = 0
    Timers:CreateTimer(0.05, function()
    	created_projectile = created_projectile + 1
    	angle = (created_projectile*90)/fire
        projectileTable.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,angle-60,0), caster:GetForwardVector()) * 600
        fire_spear_simple = ProjectileManager:CreateLinearProjectile( projectileTable )
        if created_projectile <= fire then
            return 0.05
        end
    end)
end

function projectile_fire_spear( keys )
    local ability = keys.ability
    local caster = keys.caster

    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/fire_spear.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = 5000,
        fStartRadius = 50,
        fEndRadius = 50,
        fExpireTime = GameRules:GetGameTime() + 5,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = caster:GetForwardVector() * 600,
        vAcceleration = caster:GetForwardVector() * 200
    }
    fire_spear_simple = ProjectileManager:CreateLinearProjectile(projectileTable)
    print (fire_spear_simple)
    caster.projectile_table[1] = fire_spear_simple
end

function projectile_iceshard1(keys , ice, wind, fire)
    local ability = keys.ability
    local caster = keys.caster
    local distance = 600*(ice+wind)/5
    local speed = 600 * (fire/5 + 1)
    local forward = caster:GetForwardVector()

    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/crystal_maiden_projectil_spawner_work.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = distance,
        fStartRadius = 50+fire*5,
        fEndRadius = 50+fire*5,
        fExpireTime = GameRules:GetGameTime() + 5,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = forward * 300,
    }
    main_projectile = ProjectileManager:CreateLinearProjectile(projectileTable)
end
function projectile_iceshard2(keys , ice, wind, fire)
    local ability = keys.ability
    local caster = keys.caster
    local projectile_count = math.floor((ice+wind)/2 )
    local number_of_source = math.ceil((ice+wind)/4 )
    local delay = 1.0
    local distance = 600*(ice+wind)/5
    local time_interval = 0.20
    local speed = 600 * (fire/5 + 1)
    local forward = caster:GetForwardVector()

    local casterPoint = caster:GetAbsOrigin()
    print (delay)
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/crystal_maiden_projectil_spawner_work.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = 900 + (delay * 300),
        fStartRadius = 150,
        fEndRadius = 150,
        fExpireTime = GameRules:GetGameTime() + 6,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = forward * 300,
    }
        main_projectile = ProjectileManager:CreateLinearProjectile(projectileTable)
        caster.projectile_table[1] = main_projectile
    local secondary_projectile = {
        Ability = ability,
        EffectName = "particles/ice_spear.vpcf",
        vSpawnOrigin = casterPoint + forward * 600,
        fDistance = distance,
        fStartRadius = 50,
        fEndRadius = 50,
        fExpireTime = GameRules:GetGameTime() + 10,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = true,
        vVelocity = forward * 600,
    }

    --Creates the projectiles in 360 degrees
    if number_of_source == 1 or number_of_source > 2 then
        Timers:CreateTimer(delay,function()
            local projectiles_created = 0
            for i=-180,180,(180/projectile_count) do
                i = i+180
                local time = projectiles_created * time_interval
                projectiles_created = projectiles_created + 1

                --EmitSoundOn("", caster) --Add a sound if you wish!
                Timers:CreateTimer(time, function()
                    secondary_projectile.vSpawnOrigin = casterPoint + (forward * 300 * time) + forward * 300* delay + forward * 75
                    secondary_projectile.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), forward) * speed
                    small_projectile = ProjectileManager:CreateLinearProjectile( secondary_projectile )
                end)
            end
        end)
    end
    if number_of_source >=2 then
        Timers:CreateTimer(delay,function()
            local projectiles_created = 0
            for i=-180,180,(180/projectile_count) do
                if number_of_source == 3 then
                    i = i - 30
                end
                i = i+90
                local time = projectiles_created * time_interval
                projectiles_created = projectiles_created + 1

                --EmitSoundOn("", caster) --Add a sound if you wish!
                Timers:CreateTimer(time, function()
                    secondary_projectile.vSpawnOrigin = casterPoint + (forward * 300 * time) + forward * 300 * delay + forward * 75
                    secondary_projectile.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), forward) * speed
                    small_projectile = ProjectileManager:CreateLinearProjectile( secondary_projectile )
                end)
            end
        end)
    end
    if number_of_source >=2 then
        Timers:CreateTimer(delay,function()
            local projectiles_created = 0
            for i=-180,180,(180/projectile_count) do
                i = i+270
                if number_of_source == 3 then
                    i = i + 30
                end
                local time = projectiles_created * time_interval
                projectiles_created = projectiles_created + 1

                --EmitSoundOn("", caster) --Add a sound if you wish!
                Timers:CreateTimer(time, function()
                    secondary_projectile.vSpawnOrigin = casterPoint + (forward * 300 * time) + forward * 300* delay + forward * 75
                    secondary_projectile.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), forward) * speed
                    small_projectile = ProjectileManager:CreateLinearProjectile( secondary_projectile )
                end)
            end
        end)
    end
    if number_of_source == 4 then
        Timers:CreateTimer(delay,function()
            local projectiles_created = 0
            for i=-180,180,(180/projectile_count) do
                local time = projectiles_created * time_interval
                projectiles_created = projectiles_created + 1

                --EmitSoundOn("", caster) --Add a sound if you wish!
                Timers:CreateTimer(time, function()
                    secondary_projectile.vSpawnOrigin = casterPoint + (forward * 300 * time) + forward * 300* delay + forward * 75
                    secondary_projectile.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), forward) * speed
                    small_projectile = ProjectileManager:CreateLinearProjectile( secondary_projectile )
                end)
            end
        end)
    end
end