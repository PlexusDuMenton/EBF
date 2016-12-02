-- Custom Stat Values
require( "libraries/Timers" )
HP_PER_STR = 18
HP_REGEN_PER_STR = 0.025
MANA_PER_INT = 3
MANA_REGEN_PER_INT = 0.035
ARMOR_PER_AGI = 0.08
ATKSPD_PER_AGI = 0.15
DMG_PER_INT = 0.75
MAX_MOVE_SPEED = 1500

-- Default Dota Values
DEFAULT_HP_PER_STR = 20
DEFAULT_HP_REGEN_PER_STR = 0.03
DEFAULT_MANA_PER_INT = 12
DEFAULT_MANA_REGEN_PER_INT = 0.04
DEFAULT_ARMOR_PER_AGI = 0.14
DEFAULT_ATKSPD_PER_AGI = 1.0

THINK_INTERVAL = 0.25

if stats == nil then
	stats = class({})
end

function stats:ModifyStatBonuses(unit)
	local hero = unit
	local applier = CreateItem("item_stat_modifier", nil, nil)

	local hp_adjustment = HP_PER_STR - DEFAULT_HP_PER_STR
	local hp_regen_adjustment = HP_REGEN_PER_STR - DEFAULT_HP_REGEN_PER_STR
	local mana_adjustment = MANA_PER_INT - DEFAULT_MANA_PER_INT
	local mana_regen_adjustment = MANA_REGEN_PER_INT - DEFAULT_MANA_REGEN_PER_INT
	local armor_adjustment = ARMOR_PER_AGI - DEFAULT_ARMOR_PER_AGI
	local attackspeed_adjustment = ATKSPD_PER_AGI - DEFAULT_ATKSPD_PER_AGI
	local damage_adjustment = DMG_PER_INT

	Timers:CreateTimer(function()

		if not IsValidEntity(hero) then
			return
		end

		-- Initialize value tracking
		if not hero.custom_stats then
			hero.custom_stats = true
			hero.strength = 0
			hero.agility = 0
			hero.intellect = 0
			hero.movespeed = 0
		end

		-- Get player attribute values
		local strength = hero:GetStrength()
		local agility = hero:GetAgility()
		local intellect = hero:GetIntellect()
		local movespeed = hero:GetIdealSpeed()
		
		-- Adjustments

		-- STR
		if strength ~= hero.strength then
			-- HP Bonus
			if not hero:HasModifier("modifier_health_bonus") then
				applier:ApplyDataDrivenModifier(hero, hero, "modifier_health_bonus", {})
			end

			local health_stacks = strength * hp_adjustment
			hero:SetModifierStackCount("modifier_health_bonus", hero, health_stacks)
		end

		-- AGI
		if agility ~= hero.agility then
			-- Armor Bonus
			if not hero:HasModifier("modifier_physical_armor_bonus") then
				applier:ApplyDataDrivenModifier(hero, hero, "modifier_physical_armor_bonus", {})
			end

			local armor_stacks = agility * armor_adjustment * 100
			hero:SetModifierStackCount("modifier_physical_armor_bonus", hero, armor_stacks)
			
			hero:SetPhysicalArmorBaseValue(agility * armor_adjustment)

			-- Attack Speed Bonus
			if not hero:HasModifier("modifier_attackspeed_bonus_constant") then
				applier:ApplyDataDrivenModifier(hero, hero, "modifier_attackspeed_bonus_constant", {})
			end

			local attackspeed_stacks = agility * attackspeed_adjustment * -1
			hero:SetModifierStackCount("modifier_attackspeed_bonus_constant", hero, attackspeed_stacks)
		end

		-- INT
		if intellect ~= hero.intellect then
			--damage boost per int
			if not hero:HasModifier("modifier_mana_bonus") then
				applier:ApplyDataDrivenModifier(hero, hero, "modifier_mana_bonus", {})
			end

			local damage_stacks = intellect * mana_adjustment * 10
			hero:SetModifierStackCount("modifier_mana_bonus", hero, damage_stacks)

			if not hero:HasModifier("modifier_base_damage") then
				applier:ApplyDataDrivenModifier(hero, hero, "modifier_base_damage", {})
			end

			local damage_stacks = intellect * damage_adjustment * 100
			hero:SetModifierStackCount("modifier_base_damage", hero, damage_stacks)
		end

		-- Update the stored values for next timer cycle
		hero.strength = strength
		hero.agility = agility
		hero.intellect = intellect
		hero.movespeed = movespeed

		return THINK_INTERVAL
	end)
end