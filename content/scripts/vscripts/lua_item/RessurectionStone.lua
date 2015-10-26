require( "libraries/Timers" )

if RessurectionStone == nil then
	print ( '[RessurectionStone] creating RessurectionStone' )
	RessurectionStone = {} -- Creates an array to let us beable to index RessurectionStone when creating new functions
	RessurectionStone.__index = RessurectionStone
end
 
function RessurectionStone:new() -- Creates the new class
	print ( '[RessurectionStone] RessurectionStone:new' )
	o = o or {}
	setmetatable( o, RessurectionStone )
	return o
end

function RessurectionStone:start() -- Runs whenever the RessurectionStone.lua is ran
	print('[RessurectionStone] RessurectionStone started!')
end

function Ressurection(keys)
        local killedUnit = EntIndexToHScript( keys.caster_entindex )
        local itemName = tostring(keys.ability:GetAbilityName())
        for itemSlot = 0, 5, 1 do
                local Item = killedUnit:GetItemInSlot( itemSlot )
                if Item ~= nil and Item:GetName() == itemName and killedUnit:IsRealHero()  then
                        print ('YOLO')
                        if not killedUnit:IsAlive() then
                                Timers:CreateTimer(2,function()
                                        killedUnit:RespawnHero(false, false, false)
                                        if Item:GetCurrentCharges() == 1 then
                                        	killedUnit:RemoveItem(Item)
                                   		end
                                        if Item:GetCurrentCharges() > 1 then
                                        	Item:SetCurrentCharges(Item:GetCurrentCharges()-1)
                                        end
                                end)
                        end
                end
        end
end