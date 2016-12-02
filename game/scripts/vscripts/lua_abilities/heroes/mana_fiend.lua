require("libraries/utility")

function LifeToMana(keys)
	local ability = keys.ability
	local caster = keys.caster
	local currhp = caster:GetHealth()
	local manatohppct = ability:GetSpecialValueFor("life_to_mana_pct")  / 100
	local manatohp = manatohppct * ability:GetSpecialValueFor("life_efficiency")  / 100
	
	local mana = currhp * manatohp
	local newhp = currhp - mana
	caster:GiveMana(mana)
	caster:SetHealth(newhp)
end

function SpendMana(keys)
	local ability = keys.ability
	local caster = keys.caster
	local manapct = ability:GetSpecialValueFor("curr_mana_leech")  / 100
	
	ability.manaspent = caster:GetMana() * 0.6
	caster:SpendMana(ability.manaspent, ability)
	
	local manatodamage = ability:GetSpecialValueFor("mana_to_damage")
	ability.damagelance = ability.manaspent * manatodamage
end

function ProjectileDamage(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	
	local damage = ability.damagelance
	
	local messagesent = false
	
	if not caster.essence_crit_chance then caster.essence_crit_chance = 0 end
	if not caster.essence_crit_mult then caster.essence_crit_mult = 1 end
	if not caster.critprng then caster.critprng = 0 end
	if math.random(100 - caster.critprng) < caster.essence_crit_chance then
		damage = damage * caster.essence_crit_mult
		local manaburn = caster:GetMana() * 0.6^caster.essence_crit_mult
		print(manaburn)
		caster:EmitSound("Hero_TemplarAssassin.Meld.Attack")
		target:ShowPopup( {
                    PostSymbol = 4,
                    Color = Vector( 125, 125, 255 ),
                    Duration = 0.7,
                    Number = damage,
                    pfx = "spell"} )
		caster.critprng = 0
		messagesent = true
		caster:SetMana(manaburn)
		caster.essencecritactive = true
	else
		caster.critprng = caster.critprng + 1
		caster.essencecritactive = false
	end
	ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability })
	
	if not messagesent then
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, damage, nil)
	end
end

function MagicDamage( keys )
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local damage = ability.damage
	local messagesent = false
	if not caster.essence_crit_chance then caster.essence_crit_chance = 0 end
	if not caster.essence_crit_mult then caster.essence_crit_mult = 1 end
	if not caster.critprng then caster.critprng = 0 end
	local manaburn = ability:GetManaCost(-1) * caster.essence_crit_mult
	if math.random(100-caster.critprng) < caster.essence_crit_chance and caster:GetMana() >= manaburn then
		damage = damage * caster.essence_crit_mult
		
		caster:EmitSound("Hero_TemplarAssassin.Meld.Attack")
		target:ShowPopup( {
                    PostSymbol = 4,
                    Color = Vector( 125, 125, 255 ),
                    Duration = 0.7,
                    Number = damage,
                    pfx = "spell_custom"} )
		caster.critprng = 0
		messagesent = true
		caster:SpendMana(manaburn, ability)
		caster.essencecritactive = true
	else
		caster.critprng = caster.critprng + 1
		caster.essencecritactive = false
	end

	local damage_table = {}

	damage_table.attacker = caster
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.ability = ability
	damage_table.victim = target
	damage_table.damage = damage 
	if not messagesent then
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, damage, nil)
	end
	ApplyDamage(damage_table)

end

function CritUpgrade(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	caster.essence_crit_chance = ability:GetSpecialValueFor("crit_chance")
	caster.essence_crit_mult = ability:GetSpecialValueFor("crit_amp") / 100
end

function ManageToggle( keys )
	local ability = keys.ability
	local caster = keys.caster
	caster:RemoveModifierByName(keys.reduction)
	if ability:GetToggleState() and caster:GetMana() > ability:GetManaCost(-1) then
		local damage_caster = caster:GetAverageTrueAttackDamage()
		local magic_damage = ability:GetSpecialValueFor("damage_to_magic")  / 100
		if not caster:HasModifier(keys.orb) then ability:ApplyDataDrivenModifier(caster, caster, keys.orb, {}) end
		
		ability:ApplyDataDrivenModifier(caster, caster, keys.reduction, {})
		caster:SetModifierStackCount( keys.reduction, ability, damage_caster*magic_damage )
		ability.damage = damage_caster*magic_damage
	else
		caster:RemoveModifierByName(keys.orb)
		caster:RemoveModifierByName(keys.reduction)
	end
end
