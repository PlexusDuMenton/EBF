require( "libraries/Timers" )

if simple_item == nil then
    print ( '[simple_item] creating simple_item' )
    simple_item = {} -- Creates an array to let us beable to index simple_item when creating new functions
    simple_item.__index = simple_item
end

-- Clears the force attack target upon expiration
function BerserkersCallEnd( keys )
    local target = keys.target

    target:SetForceAttackTarget(nil)
end

function simple_item:new() -- Creates the new class
    print ( '[simple_item] simple_item:new' )
    o = o or {}
    setmetatable( o, simple_item )
    return o
end

function simple_item:start() -- Runs whenever the simple_item.lua is ran
    print('[simple_item] simple_item started!')
end
function Cooldown_powder(keys)
    local item = keys.ability
    if GetMapName() == "epic_boss_fight_impossible" then
        item:StartCooldown(60)
    end
    if GetMapName() == "epic_boss_fight_hard" then
        item:StartCooldown(30)
    end
    if GetMapName() == "epic_boss_fight_normal" then
        item:StartCooldown(15)
    end
end

function ares_powder(keys)
    local caster = keys.caster
    local radius = item:GetLevelSpecialValueFor("Radius", 0)
    caster.ennemyunit = FindUnitsInRadius(caster:GetTeam(),
                              caster:GetAbsOrigin(),
                              nil,
                              radius,
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
    for _,unit in pairs(caster.ennemyunit) do
        unit:SetForceAttackTarget(nil)
        if caster:IsAlive() then
            local order = 
            {
                UnitIndex = target:entindex(),
                OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                TargetIndex = caster:entindex()
            }
            ExecuteOrderFromTable(order)
        else
            unit:Stop()
        end
        unit:SetForceAttackTarget(caster)
    end
end
function ares_powder_end(keys)

    for _,unit in pairs(caster.ennemyunit) do
        unit:SetForceAttackTarget(nil)
    end
end
function blood_booster(keys)
    local caster = keys.caster
    local item = keys.ability
    local modifierName = "blood_booster"
    caster.tank_booster = true
    local health_stacks = 0
    
    if caster:IsRealHero() then 
        local testcount = 0
        Timers:CreateTimer(0.1,function()
            if caster.tank_booster == true then
                local str = caster:GetStrength()
                if str ~= health_stacks then
                    health_stacks = caster:GetStrength()
                    adjute_HP(keys)
                    if caster:HasModifier( modifierName ) then
                        caster:SetModifierStackCount( modifierName, caster, health_stacks)
                    else
                        item:ApplyDataDrivenModifier( caster, caster, modifierName, {})
                        caster:SetModifierStackCount( modifierName, caster, health_stacks)
                    end
                end  
                return 0.2
            else
                caster:SetModifierStackCount( modifierName, caster, 0)
            end
        end)
    end
end


function blood_booster_end(keys)
    local caster = keys.caster
    caster.tank_booster = false
end

function tank_booster(keys)
    local caster = keys.caster
    local item = keys.ability
    local modifierName = "health_booster"
    caster.tank_booster = true
    local health_stacks = 0
    
    if caster:IsRealHero() then 
        local testcount = 0
        Timers:CreateTimer(0.1,function()
            if caster.tank_booster == true then
                local str = caster:GetStrength()
                if str ~= health_stacks then
                    health_stacks = caster:GetStrength()
                    adjute_HP(keys)
                    if caster:HasModifier( modifierName ) then
                        caster:SetModifierStackCount("health_booster", caster, health_stacks)
                    else
                        item:ApplyDataDrivenModifier( caster, caster, modifierName, {})
                        caster:SetModifierStackCount( modifierName, caster, health_stacks)
                    end
                end  
                return 0.2
            else
                caster:SetModifierStackCount("health_booster", caster, 0)
            end
        end)
    end
end

function adjute_HP(keys)
    local caster = keys.caster
    local ability = keys.ability
    local modifierName = "health_fix"
    ability:ApplyDataDrivenModifier( caster, caster, modifierName, {duration = 0.1})
    caster:SetModifierStackCount( modifierName, ability, 1)
end

function tank_booster_end(keys)
    local caster = keys.caster
    caster.tank_booster = false
end

function Pierce(keys)
    local caster = keys.caster
    local target = keys.target
    local item = keys.ability
    local percent = item:GetLevelSpecialValueFor("Pierce_percent", 0)
    local damage = keys.damage_on_hit*percent*0.01
    local damageTable = {victim = target,
                attacker = caster,
                damage = damage,
                damage_type = DAMAGE_TYPE_PURE,
                }
    ApplyDamage(damageTable)
end

function Midas_OnHit(keys)
    local caster = keys.caster
    local item = keys.ability
    local damage = keys.damage_on_hit
    local bonus_gold = math.floor(damage ^ 0.08 /2) + 1
    local ID = 0

    if item:IsCooldownReady() and not caster:IsIllusion() then
        for ID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
            if PlayerResource:GetTeam( ID ) == DOTA_TEAM_GOODGUYS then
                    local totalgold = PlayerResource:GetSelectedHeroEntity(ID):GetGold() + bonus_gold
                    PlayerResource:GetSelectedHeroEntity(ID):SetGold(0 , false)
                    PlayerResource:GetSelectedHeroEntity(ID):SetGold(totalgold, true)
            end
        end
        item:StartCooldown(0.25)
    end
end

function check_admin(keys)
    local caster = keys.caster
    local item = keys.ability
    local ID = caster:GetPlayerID()
    if PlayerResource:GetSteamAccountID( ID ) == 42452574 then
        print ("Here is the Nerf hammer in the hand of the great lord FrenchDeath")
    else
        Timers:CreateTimer(0.3,function()
            FireGameEvent( 'custom_error_show', { player_ID = ID, _error = "YOU HAVE NO RIGHT TO HAVE THIS ITEM!" } )
            caster:RemoveItem(item)
        end)
    end
end

function Midas2_OnHit(keys)
    local caster = keys.caster
    local item = keys.ability
    local damage = keys.damage_on_hit
    local bonus_gold = math.floor(damage ^ 0.13 / 2) + 1
    local ID = 0

    if item:IsCooldownReady() and not caster:IsIllusion() then
        for ID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
            if PlayerResource:GetTeam( ID ) == DOTA_TEAM_GOODGUYS then
                    local totalgold = PlayerResource:GetSelectedHeroEntity(ID):GetGold() + bonus_gold
                    PlayerResource:GetSelectedHeroEntity(ID):SetGold(0 , false)
                    PlayerResource:GetSelectedHeroEntity(ID):SetGold(totalgold, true)
            end
        end
        item:StartCooldown(0.20)
    end
end

function Berserker(keys)
    local caster = keys.caster
    local target = keys.target
    local item = keys.ability
    local health_reduction = item:GetLevelSpecialValueFor("health_percent_lose", item:GetLevel()-1) * caster:GetMaxHealth() * 0.01
    local damage_total = item:GetLevelSpecialValueFor("health_percent_damage", item:GetLevel()-1) * caster:GetMaxHealth() * 0.01

    if caster:IsRealHero() then
        caster:SetHealth(caster:GetHealth()-health_reduction)
        if caster:GetHealth() <=0 then
          caster:SetHealth(1)
        end
        local damageTable = {victim = target,
                        attacker = caster,
                        damage = damage_total,
                        damage_type = DAMAGE_TYPE_PHYSICAL,
                        }
        ApplyDamage(damageTable)
    end
end

function Crests(keys)
    local caster = keys.caster
    local target = keys.target
    local item = keys.ability

    local armor_percent = item:GetLevelSpecialValueFor("active_armor_percent", 0) * 0.01
    local active_damage_reduction = item:GetLevelSpecialValueFor("active_damage_reduction", 0)
    local active_duration = item:GetLevelSpecialValueFor("active_duration", 0)

    local new_armor_target = math.floor(target:GetPhysicalArmorValue() * (armor_percent))
    local new_armor_caster = math.floor(caster:GetPhysicalArmorValue() * (armor_percent))

    local armor_modifier = "crest_armor_reduction"
    local debuff = "crest_debuff"
    item:ApplyDataDrivenModifier(caster, target, armor_modifier, { duration = active_duration })
    target:SetModifierStackCount( armor_modifier, item, new_armor_target )

    item:ApplyDataDrivenModifier(caster, target, debuff, { duration = active_duration })
    target:SetModifierStackCount( debuff, item, 1 )


    item:ApplyDataDrivenModifier(caster, caster, armor_modifier, { duration = active_duration })
    caster:SetModifierStackCount( armor_modifier, item, new_armor_caster )

    item:ApplyDataDrivenModifier(caster, caster, debuff, { duration = active_duration })
    caster:SetModifierStackCount( debuff, item, 1 )
end

function veil(keys)
    local item = keys.ability
    local point = keys.target_points[1]

    local Magical_ress_reduction = item:GetLevelSpecialValueFor("MR_debuff", 0)
    local active_duration = item:GetLevelSpecialValueFor("active_duration", 0)
    local debuff_radius = item:GetLevelSpecialValueFor("debuff_radius", 0)
    local debuff = "veil_debuff"
    local nearbyUnits = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                              point,
                              nil,
                              debuff_radius,
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
    local new_armor_target =  0
    for _,unit in pairs(nearbyUnits) do
        --[[if unit.oldMR ~= nil then
            unit.oldMR = (unit:GetBaseMagicalResistanceValue() - unit.lastusedmr)
        end
        unit.oldMR = unit:GetBaseMagicalResistanceValue()
        unit.lastusedmr = Magical_ress_reduction
        ]]
        new_armor_target =  math.floor(unit:GetBaseMagicalResistanceValue()  + Magical_ress_reduction)
        
        unit:SetBaseMagicalResistanceValue(new_armor_target)
        item:ApplyDataDrivenModifier(caster, unit, debuff, { duration = active_duration })
        unit:SetModifierStackCount( debuff, item, 1 )
    end
end

function restoremagicress(keys)
    print ("test")
    local item = keys.ability
    local unit = keys.target
    local Magical_ress_reduction = item:GetLevelSpecialValueFor("MR_debuff", 0)
    --unit.oldMR = true
    unit:SetBaseMagicalResistanceValue(unit:GetBaseMagicalResistanceValue() - Magical_ress_reduction)
end

function Splash(keys)
    local caster = keys.caster
    local target = keys.target
    local item = keys.ability
    local radius = item:GetLevelSpecialValueFor("radius", 0)
    local percent = item:GetLevelSpecialValueFor("splash_damage", 0)
    local damage = keys.damage_on_hit*percent*0.01
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
            local damageTable = {victim = unit,
                        attacker = caster,
                        damage = damage,
                        damage_type = DAMAGE_TYPE_PHYSICAL,
                        }
            ApplyDamage(damageTable)
        end
    end
end

function Splash_melee(keys)
    local caster = keys.caster
    local target = keys.target
    local item = keys.ability
    local radius = item:GetLevelSpecialValueFor("radius", 0)
    local percent = item:GetLevelSpecialValueFor("splash_damage", 0)
    local damage = keys.damage_on_hit*percent*0.01
    local nearbyUnits = FindUnitsInRadius(target:GetTeam(),
                              target:GetAbsOrigin(),
                              nil,
                              radius,
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
    if caster:IsRangedAttacker() == false then
        for _,unit in pairs(nearbyUnits) do
            local damageTable = {victim = unit,
                                attacker = caster,
                                damage = damage,
                                damage_type = DAMAGE_TYPE_PURE,
                                }
            ApplyDamage(damageTable)
        end
    end
end