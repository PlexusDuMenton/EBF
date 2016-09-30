function AghsCheck(keys)
	if keys.caster:HasScepter() then
		keys.ability:ApplyDataDrivenModifier(keys.caster,keys.target,"purifying_flames_scepter",nil)
	end
end

function FlameDamage(keys)
	ApplyDamage({ victim = keys.target, attacker = keys.caster, damage = keys.damage, damage_type = keys.ability:GetAbilityDamageType(), ability = keys.ability })
end

function FlameHealCreate(keys)
	local ability = keys.ability
	local target = keys.target
	local caster = keys.caster
	local heal = ability:GetLevelSpecialValueFor("heal_per_second", ability:GetLevel()-1)
	if ability.stack == nil then ability.stack = 0 end
	ability.stack = ability.stack + 1
	target:RemoveModifierByName("purifying_flames_heal_counter")
	ability:ApplyDataDrivenModifier(caster,target,"purifying_flames_heal_counter",nil)
	target:SetModifierStackCount( "purifying_flames_heal_counter", ability, ability.stack)
	target:Heal(heal,keys.caster)
end

function FlameHeal(keys)
	local ability = keys.ability
	local target = keys.target
	local caster = keys.caster
	local heal = ability:GetLevelSpecialValueFor("heal_per_second", ability:GetLevel()-1)
	if ability.stack == nil then ability.stack = 0 end
	target:Heal(heal,keys.caster)
end

function FlameHealDestroy(keys)
	local ability = keys.ability
	if ability.stack == nil then ability.stack = 1 end
	ability.stack = ability.stack - 1
	keys.target:SetModifierStackCount( "purifying_flames_heal_counter", ability, ability.stack)
	if ability.stack == 0 then keys.target:RemoveModifierByName("purifying_flames_heal_counter") end
end

function ShareUpgrade(keys)
	local caster = keys.caster
	local this_ability = keys.ability	
		local this_abilityName = this_ability:GetAbilityName()
		local this_abilityLevel = this_ability:GetLevel()	
			-- The ability to level up
		local ability_name = keys.twin
		if caster:FindAbilityByName(ability_name) then
			local ability_handle = caster:FindAbilityByName(ability_name)	
			local ability_level = ability_handle:GetLevel()
			-- Check to not enter a level up loop
			if ability_level ~= this_abilityLevel then
				ability_handle:SetLevel(this_abilityLevel)
			end
		end
end

function AghsCounterUp(keys)
	local ability = keys.ability
	local target = keys.target
	local caster = keys.caster
	if ability.stack == nil then ability.stack = 0 end
	ability.stack = ability.stack + 1
	target:RemoveModifierByName("purifying_flames_scepter_counter")
	ability:ApplyDataDrivenModifier(caster,target,"purifying_flames_scepter_counter",nil)
	target:SetModifierStackCount( "purifying_flames_scepter_counter", ability, ability.stack)
end

function AghsCounterDown(keys)
	local ability = keys.ability
	if ability.stack == nil then ability.stack = 1 end
	ability.stack = ability.stack - 1
	keys.target:SetModifierStackCount( "purifying_flames_scepter_counter", ability, ability.stack)
	if ability.stack == 0 then keys.target:RemoveModifierByName("purifying_flames_scepter_counter") end
end