LinkLuaModifier( "outside_map_ability_modifier", "lua_map/outside_hurt_mod.lua", LUA_MODIFIER_MOTION_NONE )

function OnStartTouch(trigger)
    local ent = trigger.activator
    print ('YOLO')
    if not ent then return end
    if ent:IsAlive() then
    ent:AddNewModifier( ent, self, "outside_map_ability_modifier", {} )
        return
    end
end

function OnEndTouch(trigger)
    local ent = trigger.activator
    if not ent then return end
    if ent:IsAlive() then
    ent:RemoveModifierByName("outside_map_ability_modifier") 
        return
    end
end