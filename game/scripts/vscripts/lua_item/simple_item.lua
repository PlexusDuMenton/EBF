require( "libraries/Timers" )
require( "lua_abilities/Check_Aghanim" )

if simple_item == nil then
    print ( '[simple_item] creating simple_item' )
    simple_item = {} -- Creates an array to let us beable to index simple_item when creating new functions
    simple_item.__index = simple_item
    simple_item.midas_gold_on_round = 0
    simple_item._round = 1
end

-- Clears the force attack target upon expiration
function BerserkersCallEnd( keys )
    local target = keys.target

    target:SetForceAttackTarget(nil)
end

function simple_item:SetRoundNumer(round)
    simple_item._round = round
    simple_item.midas_gold_on_round = 0
    print (simple_item._round)
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

function simple_item:midas_gold(bonus) -- Runs whenever the simple_item.lua is ran
    if simple_item._totalgold == nil then 
        simple_item._totalgold = 0 
        CustomGameEventManager:Send_ServerToAllClients("create_midas_display", {})
    end
    simple_item._totalgold = simple_item._totalgold + bonus
    CustomGameEventManager:Send_ServerToAllClients("Update_Midas_Gold", {gold = simple_item._totalgold})
end

function Cooldown_powder(keys)
    local item = keys.ability
    local caster = keys.caster
    local dust_effect = ParticleManager:CreateParticle("particles/chronos_powder.vpcf", PATTACH_ABSORIGIN  , caster)
    ParticleManager:SetParticleControl(dust_effect, 0, caster:GetAbsOrigin())
    if GetMapName() == "epic_boss_fight_impossible" or GetMapName() == "epic_boss_fight_challenger" then
        item:StartCooldown(30)
    end
    if GetMapName() == "epic_boss_fight_hard" then
        item:StartCooldown(20)
    end
    if GetMapName() == "epic_boss_fight_normal" then
        item:StartCooldown(10)
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

function tank_booster(keys)
    local caster = keys.caster
    local item = keys.ability
    print ("test")
    local modifierName = "health_booster"
    caster.tank_booster = true
    local health_stacks = 0
    
    if caster:IsRealHero() then 
        Timers:CreateTimer(0.5,function()
            health_stacks = caster:GetStrength()
            if caster:GetModifierStackCount( modifierName, item ) ~= health_stacks and caster.tank_booster == true and item ~= nil then
                item:ApplyDataDrivenModifier( caster, caster, modifierName, {})
                caster:SetModifierStackCount( modifierName, caster, health_stacks)
                adjute_HP(keys)
            end
            return 0.5
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
    caster:SetModifierStackCount("health_booster", caster, 0)
    caster:RemoveModifierByName( "health_booster" )
end

function Have_Item(unit,item_name)
    local haveit = false
    for itemSlot = 0, 5, 1 do
        local Item = unit:GetItemInSlot( itemSlot )
        if Item ~= nil and Item:GetName() == item_name then
            haveit = true
        end
    end
    return haveit
end


function scale_asura(keys)
    local caster = keys.caster
    local item = keys.ability
    
        Timers:CreateTimer(2.0,function()
                local stack = GameRules._roundnumber
                caster:SetModifierStackCount( "scale_per_round", caster, stack)
                caster:SetModifierStackCount( "scale_display", caster, stack)
                if Have_Item(caster,item:GetName()) == true then
                    return 2.0
                end
        end)

end

function Berserker(keys)
    local caster = keys.caster
    local target = keys.target
    local item = keys.ability
    caster.check = true
    
    Timers:CreateTimer(0.5,function()
        if HasCustomItem(caster,item) then
            local damage_total = item:GetLevelSpecialValueFor("health_percent_damage", item:GetLevel()-1) * caster:GetMaxHealth() * 0.01
            if caster:GetModifierStackCount( "berserker_bonus_damage", ability ) ~= damage_total and caster.check == true and item ~= nil then
                if caster:IsRealHero() then
                    item:ApplyDataDrivenModifier(caster, caster, "berserker_bonus_damage", {})
                    caster:SetModifierStackCount( "berserker_bonus_damage", item, damage_total )
                end
            end
            return 0.5
        end
    end)
end

function Berserker_destroy(keys)
    local caster = keys.caster
    local target = keys.target
    local item = keys.ability
    local health_reduction = item:GetLevelSpecialValueFor("health_percent_lose", item:GetLevel()-1) * caster:GetMaxHealth() * 0.01
    caster.check = false
    Timers:CreateTimer(0.1,function()
        caster:SetModifierStackCount( "berserker_bonus_damage", item, 0 )
        caster:RemoveModifierByName( "berserker_bonus_damage" )
    end)
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

function CD_divine_armor(keys)
    keys.ability:StartCooldown(33)
end

function CD_Bahamut(keys)
    for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
        if unit:GetTeam() == DOTA_TEAM_GOODGUYS then
            for itemSlot = 0, 5, 1 do --a For loop is needed to loop through each slot and check if it is the item that it needs to drop
                    if unit ~= nil then --checks to make sure the killed unit is not nonexistent.
                        local Item = unit:GetItemInSlot( itemSlot ) -- uses a variable which gets the actual item in the slot specified starting at 0, 1st slot, and ending at 5,the 6th slot.
                        if Item ~= nil and Item:GetName() == "item_bahamut_chest" or Item ~= nil and Item:GetName() == "item_asura_plate" then
                            Item:StartCooldown(40)
                        end
                    end
            end
        end
    end
    for _,unit in pairs ( Entities:FindAllByName( "npc_dota_creature")) do
        if unit:GetTeam() == DOTA_TEAM_GOODGUYS and unit:HasInventory() then
            for itemSlot = 0, 5, 1 do --a For loop is needed to loop through each slot and check if it is the item that it needs to drop
                    if unit ~= nil then --checks to make sure the killed unit is not nonexistent.
                        local Item = unit:GetItemInSlot( itemSlot ) -- uses a variable which gets the actual item in the slot specified starting at 0, 1st slot, and ending at 5,the 6th slot.
                        if Item ~= nil and Item:GetName() == "item_bahamut_chest" or Item ~= nil and Item:GetName() == "item_asura_plate" then
                            Item:StartCooldown(40)
                        end
                    end
            end
        end
    end
        
end

function CD_pure(keys)
    local CD = keys.cooldown
    if keys.ability:GetCooldownTimeRemaining() <=CD then
        keys.ability:StartCooldown(CD)
    end
end

function item_blink_boots_check_charge(keys)
    local item = keys.ability

    if item:GetCurrentCharges() == 0 then item:SetCurrentCharges(1) end
    if item.blink_charge == nil then item:SetCurrentCharges(3) end

    item.blink_charge = true
    item.blink_next_charge = GameRules:GetGameTime() + 8

    Timers:CreateTimer(0.3,function() 
        if item.blink_charge == true then
            if GameRules:GetGameTime() >= item.blink_next_charge and item:GetCurrentCharges() < 3 then
                item:SetCurrentCharges(item:GetCurrentCharges()+1)
                item.blink_next_charge = GameRules:GetGameTime() + 8
            end
            return 0.3
        end
    end)
end

function item_blink_boots_stop_charge(keys)
    local item = keys.ability
    item.blink_charge = false
end

function item_blink_boots_blink(keys)
    local item = keys.ability
    local caster = keys.caster
    if item:GetCurrentCharges() > 0 then
        local nMaxBlink = 1500 
        local nClamp = 1200
        local vPoints = item:GetCursorPosition() 
        local vOrigin = caster:GetAbsOrigin()

        ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, caster)
        caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
        local vDistance = vPoints - vOrigin
        if vDistance:Length2D() > nMaxBlink then
            vPoints = vOrigin + (vPoints - vOrigin):Normalized() * nClamp
        end
        caster:SetAbsOrigin(vPoints)
        FindClearSpaceForUnit(caster, vPoints, false)
        ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, caster)
        if item:GetCurrentCharges() == 3 then
            item.blink_next_charge = GameRules:GetGameTime() + 8
        end
        item:SetCurrentCharges(item:GetCurrentCharges()-1)
        if item:GetCurrentCharges() == 0 then
            item:StartCooldown(item.blink_next_charge - GameRules:GetGameTime())
        end
    end
end


function item_dagon_datadriven_on_spell_start(keys)
    local caster = keys.caster
    local item = keys.ability
    local int_multiplier = item:GetLevelSpecialValueFor("damage_per_int", 0) 
    local damage = caster:GetIntellect() * int_multiplier + 1000
    print (damage)
    local dagon_particle = ParticleManager:CreateParticle("particles/dagon_mystic.vpcf",  PATTACH_ABSORIGIN_FOLLOW, keys.caster)
    ParticleManager:SetParticleControlEnt(dagon_particle, 1, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), false)
    local particle_effect_intensity =  caster:GetIntellect() --Control Point 2 in Dagon's particle effect takes a number between 400 and 800, depending on its level.
    ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
    
    keys.caster:EmitSound("DOTA_Item.Dagon.Activate")
    keys.target:EmitSound("DOTA_Item.Dagon5.Target")
        
    ApplyDamage({victim = keys.target, attacker = keys.caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL,})
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


function Midas_OnHit(keys)
    local caster = keys.caster
    local item = keys.ability
    local player = PlayerResource:GetPlayer( caster:GetPlayerID() )
    local damage = keys.damage_on_hit
    local bonus_gold = math.floor(damage ^ 0.08 /2) + 2
    local ID = 0
    if GetMapName() == "epic_boss_fight_impossible" or GetMapName() == "epic_boss_fight_challenger" then
                if simple_item.midas_gold_on_round <= simple_item._round*150 and item:IsCooldownReady() and not caster:IsIllusion() then
                    simple_item:midas_gold(bonus_gold)
                end
    elseif item:IsCooldownReady() and not caster:IsIllusion() then
        simple_item:midas_gold(bonus_gold)
    end
    simple_item.midas_gold_on_round = simple_item.midas_gold_on_round + bonus_gold
    if item:IsCooldownReady() and not caster:IsIllusion() then
        for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
            if GetMapName() == "epic_boss_fight_impossible" or GetMapName() == "epic_boss_fight_challenger" then
                if not unit:IsIllusion() and simple_item.midas_gold_on_round <= simple_item._round*150 then

                    local left_gold = (simple_item._round*150) - simple_item.midas_gold_on_round
                    if caster.show_popup ~= true then
                        caster.show_popup = true
                        ShowPopup( {
                        Target = keys.caster,
                        PreSymbol = 8,
                        PostSymbol = 2,
                        Color = Vector( 255, 200, 33 ),
                        Duration = 0.5,
                        Number = left_gold,
                        pfx = "gold",
                        Player = PlayerResource:GetPlayer( caster:GetPlayerID() )
                        } )
                        Timers:CreateTimer(3.0,function()
                            caster.show_popup = false
                        end)
                    end

                    local totalgold = unit:GetGold() + bonus_gold
                    unit:SetGold(0 , false)
                    unit:SetGold(totalgold, true)
                end
            else
                if not unit:IsIllusion() then
                    local totalgold = unit:GetGold() + bonus_gold
                    unit:SetGold(0 , false)
                    unit:SetGold(totalgold, true)
                    item:StartCooldown(0.25)
                end
            end
        end
    end
end

function dev_armor(keys)
    local killedUnit = EntIndexToHScript( keys.caster_entindex )
    local origin = killedUnit:GetAbsOrigin()
    Timers:CreateTimer(0.03,function()
        killedUnit:RespawnHero(false, false, false)
        killedUnit:SetAbsOrigin(origin)
    end)

end

function check_admin(keys)
    local caster = keys.caster
    local item = keys.ability
    local ID = caster:GetPlayerID()
    if ID ~= nil and PlayerResource:IsValidPlayerID( ID ) then
        if PlayerResource:GetSteamAccountID( ID ) == 42452574 then
            print ("Here is the Nerf hammer in the hand of the great lord FrenchDeath")
        else
            Timers:CreateTimer(0.3,function()
                FireGameEvent( 'custom_error_show', { player_ID = ID, error = "YOU HAVE NO RIGHT TO HAVE THIS ITEM!" } )
                caster:RemoveItem(item)
            end)
        end
    end
end

function Midas2_OnHit(keys)
    local target = keys.target
    local caster = keys.caster
    local item = keys.ability
    local player = PlayerResource:GetPlayer( caster:GetPlayerID() )
    local damage = keys.damage_on_hit
    local bonus_gold = math.floor(damage ^ 0.14 / 2) + 3
    local ID = 0
    simple_item.midas_gold_on_round = simple_item.midas_gold_on_round + bonus_gold
    if GetMapName() == "epic_boss_fight_impossible" or GetMapName() == "epic_boss_fight_challenger" then
                if simple_item.midas_gold_on_round <= simple_item._round*150 and item:IsCooldownReady() and not caster:IsIllusion() then
                    simple_item:midas_gold(bonus_gold)
                end
    elseif item:IsCooldownReady() and not caster:IsIllusion() then
        simple_item:midas_gold(bonus_gold)
    end
    if item:IsCooldownReady() and not caster:IsIllusion() then
        for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
            if GetMapName() == "epic_boss_fight_impossible" or GetMapName() == "epic_boss_fight_challenger" then
                if not unit:IsIllusion() and simple_item.midas_gold_on_round <= simple_item._round*300 then

                    local left_gold = (simple_item._round*300) - simple_item.midas_gold_on_round
                    if caster.show_popup ~= true then
                        caster.show_popup = true
                        ShowPopup( {
                        Target = keys.caster,
                        PreSymbol = 8,
                        PostSymbol = 2,
                        Color = Vector( 255, 200, 33 ),
                        Duration = 0.5,
                        Number = left_gold,
                        pfx = "gold",
                        Player = PlayerResource:GetPlayer( caster:GetPlayerID() )
                        } )
                        Timers:CreateTimer(3.0,function()
                            caster.show_popup = false
                        end)
                    end

                    local totalgold = unit:GetGold() + bonus_gold
                    unit:SetGold(0 , false)
                    unit:SetGold(totalgold, true)
                end
            else
                if not unit:IsIllusion() then
                    local totalgold = unit:GetGold() + bonus_gold
                    unit:SetGold(0 , false)
                    unit:SetGold(totalgold, true)
                    item:StartCooldown(0.20)
                end
            end
        end
    end
end



function Berserker_damage(keys)
    local caster = keys.caster
    local target = keys.target
    local item = keys.ability
    local health_reduction = item:GetLevelSpecialValueFor("health_percent_lose", item:GetLevel()-1) * caster:GetMaxHealth() * 0.01

    if caster:IsRealHero() then
        caster:SetHealth(caster:GetHealth()-health_reduction)
        if caster:GetHealth() <=0 then
          caster:SetHealth(1)
        end
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