--[[ ============================================================================================================
    Author: Rook
    Date: April 06, 2015
    Called when Chaos Meteor is cast.
    Additional parameters: keys.LandTime, keys.TravelSpeed, keys.VisionDistance, keys.EndVisionDuration, and
        keys.BurnDuration

    modified by FrenchDeath to the actual stage for Boss usage
================================================================================================================= ]]
function meteor_on_spell_start(keys)
    local caster_point = keys.caster:GetAbsOrigin()
    local target_point = keys.target_points[1]
    local caster = keys.caster
    
    local caster_point_temp = Vector(caster_point.x, caster_point.y, 0)
    local target_point_temp = Vector(target_point.x, target_point.y, 0)
    
    local point_difference_normalized = (target_point_temp - caster_point_temp):Normalized()
    local velocity_per_second = point_difference_normalized * keys.TravelSpeed
    
    StartSoundEvent("Hero_Invoker.ChaosMeteor.Cast",caster)
    StartSoundEvent("Hero_Invoker.ChaosMeteor.Loop",caster)

    --Create a particle effect consisting of the meteor falling from the sky and landing at the target point.
    local meteor_fly_original_point = (target_point - (velocity_per_second * keys.LandTime)) + Vector (0, 0, 500)  --Start the meteor in the air in a place where it'll be moving the same speed when flying and when rolling.
    local chaos_meteor_fly_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf", PATTACH_ABSORIGIN, keys.caster)
    ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 0, meteor_fly_original_point)
    ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 1, target_point)
    ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 2, Vector(1.3, 0, 0))
    
    --Chaos Meteor's travel distance is dependent on the level of Wex.  This value is stored now since leveling up Wex while the meteor is in midair should have no effect.
    local travel_distance = keys.ability:GetLevelSpecialValueFor("travel_distance", 0)
    
    --Spawn the rolling meteor after the delay.
    Timers:CreateTimer({
        endTime = keys.LandTime,
        callback = function()
            --Create a dummy unit will follow the path of the meteor, providing flying vision, sound, damage, etc.          
            local chaos_meteor_dummy_unit = CreateUnitByName("npc_dummy_blank", target_point, false, nil, nil, keys.caster:GetTeam())
            chaos_meteor_dummy_unit:AddAbility("boss_meteor")
            local chaos_meteor_unit_ability = chaos_meteor_dummy_unit:FindAbilityByName("boss_meteor")
            if chaos_meteor_unit_ability ~= nil then
                chaos_meteor_unit_ability:SetLevel(1)
                chaos_meteor_unit_ability:ApplyDataDrivenModifier(chaos_meteor_dummy_unit, chaos_meteor_dummy_unit, "meteor_property", {duration = -1})
            end
            
            keys.caster:StopSound("Hero_Invoker.ChaosMeteor.Loop")
            chaos_meteor_dummy_unit:EmitSound("Hero_Invoker.ChaosMeteor.Impact")
            chaos_meteor_dummy_unit:EmitSound("Hero_Invoker.ChaosMeteor.Loop")  --Emit a sound that will follow the meteor.
            local fire_aura_duration = keys.ability:GetLevelSpecialValueFor("burn_duration", 0)
            for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
                unit:SetHealth(unit:GetHealth()/10)
                if unit:GetHealth()<=0 then unit:FoceKill(true) end
                keys.ability:ApplyDataDrivenModifier(caster, unit, "fire_aura_debuff", {duration = fire_aura_duration})
            end
            
            --Store the damage to deal in a variable attached to the dummy unit, so leveling Exort after Meteor is cast will have no effect.
            chaos_meteor_dummy_unit.invoker_chaos_meteor_parent_caster = keys.caster
        
            local chaos_meteor_duration = travel_distance / keys.TravelSpeed
            local chaos_meteor_velocity_per_frame = velocity_per_second * .03
            
            --It would seem that the Chaos Meteor projectile needs to be attached to a particle in order to move and roll and such.
            local projectile_information =  
            {
                EffectName = "particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf",
                Ability = chaos_meteor_unit_ability,
                vSpawnOrigin = target_point,
                fDistance = travel_distance,
                fStartRadius = 0,
                fEndRadius = 0,
                Source = chaos_meteor_dummy_unit,
                bHasFrontalCone = false,
                iMoveSpeed = keys.TravelSpeed,
                bReplaceExisting = false,
                bProvidesVision = true,
                iVisionTeamNumber = keys.caster:GetTeam(),
                iVisionRadius = keys.VisionDistance,
                bDrawsOnMinimap = false,
                bVisibleToEnemies = true, 
                iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
                iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
                iUnitTargetType = DOTA_UNIT_TARGET_NONE ,
                fExpireTime = GameRules:GetGameTime() + chaos_meteor_duration + keys.EndVisionDuration,
            }
            local endTime = GameRules:GetGameTime() + chaos_meteor_duration
            Timers:CreateTimer({
                callback = function()
                    chaos_meteor_dummy_unit:SetAbsOrigin(chaos_meteor_dummy_unit:GetAbsOrigin() + chaos_meteor_velocity_per_frame)
                    if GameRules:GetGameTime() > endTime then
                        --Stop the sound, particle, and damage when the meteor disappears.
                        chaos_meteor_dummy_unit:StopSound("Hero_Invoker.ChaosMeteor.Loop")
                        chaos_meteor_dummy_unit:StopSound("Hero_Invoker.ChaosMeteor.Destroy")
                    
                        --Have the dummy unit linger in the position the meteor ended up in, in order to provide vision.
                        Timers:CreateTimer({
                            endTime = keys.EndVisionDuration,
                            callback = function()
                                chaos_meteor_dummy_unit:SetDayTimeVisionRange(0)
                                chaos_meteor_dummy_unit:SetNightTimeVisionRange(0)
                                
                                --Remove the dummy unit after the burn damage modifiers are guaranteed to have all expired.
                                Timers:CreateTimer({
                                    endTime = keys.BurnDuration,
                                    callback = function()
                                        chaos_meteor_dummy_unit:RemoveSelf()
                                    end
                                })
                            end
                        })
                        return 
                    else 
                        return .03
                    end
                end
            })
        end
    })
end

function money_and_exp_gain(keys)
    local caster = keys.caster
    for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
        unit:AddExperience (500000,false,false)
    end
    local gold = 0
    local PlayerNumber = PlayerResource:GetTeamPlayerCount() 
    print (PlayerNumber)
    local GoldMultiplier = (((PlayerNumber)+0.56)/1.8)*0.17
    gold = 90000 * GoldMultiplier
    local newItem = CreateItem( "item_bag_of_gold", nil, nil )
    newItem:SetPurchaseTime( 0 )
    newItem:SetCurrentCharges( gold )
    local drop = CreateItemOnPositionSync( caster:GetAbsOrigin(), newItem )
    local dropTarget = caster:GetAbsOrigin() + RandomVector( RandomFloat( 50, 350 ) )
    newItem:LaunchLoot( true, 300, 0.75, dropTarget )
end