function get_aether_multiplier(caster)
    local aether_multiplier = 1
    for itemSlot = 0, 5, 1 do
        local Item = caster:GetItemInSlot( itemSlot )
		if Item ~= nil then
			local itemAmp = Item:GetSpecialValueFor("spell_amp")/100
			if Item:GetName() == "item_aether_lens" then
				aether_multiplier = aether_multiplier + itemAmp
			end
			if Item:GetName() == "item_redium_lens" then
				aether_multiplier = aether_multiplier + itemAmp
			end
			if Item:GetName() == "item_sunium_lens" then
				aether_multiplier = aether_multiplier + itemAmp
			end
			if Item:GetName() == "item_omni_lens" then
				aether_multiplier = aether_multiplier + itemAmp
			end
			if Item:GetName() == "item_asura_lens" then
				aether_multiplier = aether_multiplier + itemAmp
			end
		end
    end
    return aether_multiplier
end

function MergeTables( t1, t2 )
    for name,info in pairs(t2) do
        t1[name] = info
    end
end

function table.removekey(t1, key)
    for k,v in pairs(t1) do
		if t1[k] == key then
			table.remove(t1,k)
		end
	end
	for k,v in pairs(t1) do
		print(k,v)
	end
end

function CDOTA_BaseNPC:GetAttackDamageType()
	-- 1: DAMAGE_TYPE_ArmorPhysical
	-- 2: DAMAGE_TYPE_ArmorMagical
	-- 4: DAMAGE_TYPE_ArmorPure
	local damagetype = GameRules.UnitKV[self:GetUnitName()]["AttackDamageType"]
	if damagetype == "DAMAGE_TYPE_ArmorPhysical" then
		return 1
	elseif damagetype == "DAMAGE_TYPE_ArmorMagical" then
		return 2
	elseif damagetype == "DAMAGE_TYPE_ArmorPure" then
		return 4
	else
		return 0
	end
end

function CDOTA_BaseNPC:GetDisableResistance()
	if self:IsCreature() then
		return GameRules.UnitKV[self:GetUnitName()]["Creature"]["DisableResistance"] or 0
	else
		return 0
	end
end

function CDOTABaseAbility:PiercesDisableResistance()
	if GameRules.AbilityKV[self:GetName()] then
		local truefalse = GameRules.AbilityKV[self:GetName()]["PiercesDisableReduction"] or 0
		if truefalse == 1 then
			return true
		else
			return false
		end
	else
		return false
	end
end

function CDOTABaseAbility:IsAetherAmplified()
	if GameRules.AbilityKV[self:GetName()] then
		local truefalse = GameRules.AbilityKV[self:GetName()]["IsAetherAmplified"] or 1
		if truefalse == 1 then
			return true
		else
			return false
		end
	else
		return true
	end
end

function CDOTABaseAbility:HasPureCooldown()
	if GameRules.AbilityKV[self:GetName()] then
		local truefalse = GameRules.AbilityKV[self:GetName()]["HasPureCooldown"] or 0
		if truefalse == 1 then
			return true
		else
			return false
		end
	else
		return false
	end
end

function CDOTABaseAbility:HasNoThreatFlag()
	if GameRules.AbilityKV[self:GetName()] then
		local truefalse = GameRules.AbilityKV[self:GetName()]["NoThreatFlag"] or 0
		if truefalse == 1 then
			return true
		else
			return false
		end
	else
		return false
	end
end

function get_aether_range(caster)
    local aether_range = 0
    for itemSlot = 0, 5, 1 do
        local Item = caster:GetItemInSlot( itemSlot )
		if Item ~= nil then
			local itemRange = Item:GetSpecialValueFor("cast_range_bonus")
			if Item:GetName() == "item_asura_lens" then
				if aether_range < itemRange then
					aether_range = itemRange
				end
			end
			if Item:GetName() == "item_omni_lens" then
				if aether_range < itemRange then
					aether_range = itemRange
				end
			end
			if Item:GetName() == "item_sunium_lens" then
				if aether_range < itemRange then
					aether_range = itemRange
				end
			end
			if Item:GetName() ==  "item_redium_lens" then
				if aether_range < itemRange then
					aether_range = itemRange
				end
			end
			if Item:GetName() == "item_aether_lens" then
				if aether_range < itemRange then
					aether_range = itemRange
				end
			end
		end
	end
    return aether_range
end

function CDOTA_BaseNPC:IsSlowed()
	if self:GetIdealSpeed() < self:GetBaseMoveSpeed() then return true
	else return false end
end

function CDOTA_BaseNPC:IsDisabled()
	local customModifier = false
	if self:HasModifier("creature_slithereen_crush_stun") then
		local customModifier = true
	end
	if self:IsSlowed() or self:IsStunned() or self:IsRooted() or self:IsSilenced() or self:IsHexed() or self:IsDisarmed() or customModifier then 
		return true
	else return false end
end

function CDOTA_BaseNPC:GetPhysicalArmorReduction()
	local armornpc = self:GetPhysicalArmorValue()
	local armor_reduction = 1 - (0.06 * armornpc) / (1 + (0.06 * math.abs(armornpc)))
	armor_reduction = 100 - (armor_reduction * 100)
	return armor_reduction
end

function CDOTA_BaseNPC:FindItemByName(itemname)
	for i = 0, 6 do
		local item = self:GetItemInSlot(i)
		if item and item:GetName() == itemname then 
			return item
		end
	end
end

function CDOTA_BaseNPC:ShowPopup( data )
    if not data then return end

    local target = self
    if not target then error( "ShowNumber without target" ) end
    local number = tonumber( data.Number or nil )
    local pfx = data.Type or "miss"
    local player = data.Player or false
    local color = data.Color or Vector( 255, 255, 255 )
    local duration = tonumber( data.Duration or 1 )
    local presymbol = tonumber( data.PreSymbol or nil )
    local postsymbol = tonumber( data.PostSymbol or nil )

    local path = "particles/msg_fx/msg_" .. pfx .. ".vpcf"
    local particle = ParticleManager:CreateParticle(path, PATTACH_OVERHEAD_FOLLOW, target)
    if player then
		local playerent = PlayerResource:GetPlayer( self:GetPlayerID() )
        local particle = ParticleManager:CreateParticleForPlayer( path, PATTACH_OVERHEAD_FOLLOW, target, playerent)
    end
	
	if number then
		number = math.floor(number+0.5)
	end

    local digits = 0
    if number ~= nil then digits = string.len(number) end
    if presymbol ~= nil then digits = digits + 1 end
    if postsymbol ~= nil then digits = digits + 1 end

    ParticleManager:SetParticleControl( particle, 1, Vector( presymbol, number, postsymbol ) )
    ParticleManager:SetParticleControl( particle, 2, Vector( duration, digits, 0 ) )
    ParticleManager:SetParticleControl( particle, 3, color )
end

function CDOTA_BaseNPC:IsTargeted()
	if self == GameRules.focusedUnit then
		return true
	else
		return false
	end
end

function CDOTA_BaseNPC:IncreaseStrength(amount)
	local attribute = self:GetBaseStrength()
	local strength = attribute + amount
	self:SetBaseStrength(strength)
end

function CDOTA_BaseNPC:IncreaseAgility(amount)
	local attribute = self:GetBaseAgility()
	local agility = attribute + amount
	self:SetBaseStrength(agility)
end

function CDOTA_BaseNPC:IncreaseIntellect(amount)
	local attribute = self:GetBaseIntellect()
	local intellect = attribute + amount
	self:SetBaseStrength(intellect)
end

function CDOTABaseAbility:GetTrueCooldown()
	local cooldown = self:GetCooldown(-1)
	local octarineMult = get_octarine_multiplier(self:GetCaster())
	cooldown = cooldown * octarineMult
	return cooldown
end

function RotateVector2D(vector, theta)
    local xp = vector.x*math.cos(theta)-vector.y*math.sin(theta)
    local yp = vector.x*math.sin(theta)+vector.y*math.cos(theta)
    return Vector(xp,yp,vector.z):Normalized()
end

function  CDOTABaseAbility:ApplyAOE(particles, sound, location, radius, damage, damage_type, modifier, duration)
    if duration == nil then
        duration = self:GetAbilityDuration()
    end
    if radius == nil then
        radius = self:GetCaster():GetHullRadius()*2
    end
    if damage_type == nil then
        damage_type = self:GetAbilityDamageType()
    end
    if sound ~= nil then
        StartSoundEventFromPosition(sound,location)
    end
	if location == nil then
		location = self:GetCaster():GetAbsOrigin()
	end
	if particles then
		local AOE_effect = ParticleManager:CreateParticle(particles, PATTACH_ABSORIGIN  , self:GetCaster())
		ParticleManager:SetParticleControl(AOE_effect, 0, location)
		ParticleManager:SetParticleControl(AOE_effect, 1, location)
		Timers:CreateTimer(duration,function()
			ParticleManager:DestroyParticle(AOE_effect, false)
		end)
	end

    local nearbyUnits = FindUnitsInRadius(self:GetCaster():GetTeam(),
                                  location,
                                  nil,
                                  radius,
                                  self:GetAbilityTargetTeam(),
                                  self:GetAbilityTargetType(),
                                  self:GetAbilityTargetFlags(),
                                  FIND_ANY_ORDER,
                                  false)

    for _,unit in pairs(nearbyUnits) do
        if unit ~= self:GetCaster() then
                if unit:GetUnitName()~="npc_dota_courier" and unit:GetUnitName()~="npc_dota_flying_courier" then
					if damage and damage_type then
						local damageTableAoe = {victim = unit,
									attacker = self:GetCaster(),
									damage = damage,
									damage_type = damage_type,
									ability = self,
									}
						ApplyDamage(damageTableAoe)
					end
					if modifier and unit:IsAlive() and not unit:HasModifier(modifier) then
						if self:GetClassname() == "ability_lua" then
							unit:AddNewModifier( self:GetCaster(), self, modifier, { duration = duration } )
						elseif self:GetClassname() == "ability_datadriven" then
							self:ApplyDataDrivenModifier(self:GetCaster(), unit, modifier , { duration = duration })
						end
					end
                end
        end
    end
end

function get_octarine_multiplier(caster)
    local octarine_multiplier = 1
    for itemSlot = 0, 5, 1 do
        local Item = caster:GetItemInSlot( itemSlot )
        if Item ~= nil and Item:GetName() == "item_octarine_core" then
            if octarine_multiplier > 0.75 then
                octarine_multiplier = 0.75
            end
        end
        if Item ~= nil and Item:GetName() == "item_octarine_core2" then
            if octarine_multiplier > 0.67 then
                octarine_multiplier = 0.67
            end
        end
        if Item ~= nil and Item:GetName() == "item_octarine_core3" then
            if octarine_multiplier > 0.5 then
                octarine_multiplier = 0.5
            end
        end
        if Item ~= nil and Item:GetName() == "item_octarine_core4" then
            if octarine_multiplier > 0.33 then
                octarine_multiplier =0.33
            end
        end
		if Item ~= nil and Item:GetName() == "item_octarine_core5" then
            if octarine_multiplier > 0.25 then
                octarine_multiplier = 0.25
            end
        end
		if Item ~= nil and Item:GetName() == "item_asura_core" then
            if octarine_multiplier > 0.15 then
                octarine_multiplier = 0.15
            end
        end
    end
    return octarine_multiplier
end