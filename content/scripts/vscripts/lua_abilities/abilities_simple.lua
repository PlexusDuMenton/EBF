require( "libraries/Timers" )

if abilities_simple == nil then
    print ( '[abilities_simple] creating abilities_simple' )
    abilities_simple = {} -- Creates an array to let us beable to index abilities_simple when creating new functions
    abilities_simple.__index = abilities_simple
end
 
function abilities_simple:new() -- Creates the new class
    print ( '[abilities_simple] abilities_simple:new' )
    o = o or {}
    setmetatable( o, abilities_simple )
    return o
end

function abilities_simple:start() -- Runs whenever the abilities_simple.lua is ran
    print('[abilities_simple] abilities_simple started!')
end


function HauntFunction(keys)
    print ('look like it work :)')
    local modifierName = "haunt"
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    if target:HasModifier( modifierName ) then
        local current_stack = target:GetModifierStackCount( modifierName, ability )
        ability:ApplyDataDrivenModifier( caster, target, modifierName, nil )
        target:SetModifierStackCount( modifierName, ability, current_stack + 1 )
    else
        ability:ApplyDataDrivenModifier( caster, target, modifierName, nil)
        target:SetModifierStackCount( modifierName, ability, 1)
    end
end