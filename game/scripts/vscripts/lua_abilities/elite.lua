function FrenzyStacks(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster,caster, "modifier_elite_frenzied_bonus", nil)
	caster:SetModifierStackCount("modifier_elite_frenzied_bonus",caster, GameRules._roundnumber * 10)
	caster:SetBaseAttackTime(caster:GetBaseAttackTime()/2)
end

function BurningAura(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster:IsAlive() then return end
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), 
									caster:GetAbsOrigin(), 
									caster, 
									450,
									DOTA_UNIT_TARGET_TEAM_ENEMY,
                                    DOTA_UNIT_TARGET_HERO,
                                    DOTA_UNIT_TARGET_FLAG_NONE,
                                    FIND_ANY_ORDER,
                                    false)
	for _,unit in pairs(enemies) do
		local damage = unit:GetMaxHealth() * 0.08
		if caster:HasAbility("new_game_damage_increase") then
			damage = damage/10
		end
		ability:ApplyDataDrivenModifier(caster,unit,"modifier_elite_burning_health_regen_block",{duration = 0.5})
		ApplyDamage({ victim = unit, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability })
	end
end

function ApplyAttackSlow(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	ability:ApplyDataDrivenModifier(caster,target, keys.slowmod, nil)
	local attackspeed = math.ceil(100 + target:GetIncreasedAttackSpeed() * 100)
	print(attackspeed)
	local slow = attackspeed / 2
	if attackspeed > 700 then slow = slow + (attackspeed - 700)/2 end
	target:SetModifierStackCount(keys.slowmod, caster, slow)
end

function Blink(keys)
	local point = keys.target_points[1]
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local difference = point - casterPos
	local ability = keys.ability
	local range = ability:GetLevelSpecialValueFor("blink_range", (ability:GetLevel() - 1))

	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end

	FindClearSpaceForUnit(caster, point, false)
	ProjectileManager:ProjectileDodge(caster)
	
	local blinkIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_ABSORIGIN, caster)
	Timers:CreateTimer( 1, function()
		ParticleManager:DestroyParticle( blinkIndex, false )
		return nil
		end
	)
end

function BlinkAI(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not ability:IsCooldownReady() or caster:IsAttacking() then return end
	local enemies = FindUnitsInRadius( caster:GetTeam(), caster:GetOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, 0, false )
	local minRange = caster:GetAttackRange()
	local maxRange = 9999
	local target = nil
	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (caster:GetOrigin() - enemy:GetOrigin()):Length2D()
		if enemy:IsAlive() and distanceToEnemy > minRange and distanceToEnemy < maxRange then
			maxRange = distanceToEnemy
			target = enemy
		end
	end
	if target then
		caster:SetCursorPosition(target:GetAbsOrigin() + Vector(math.random(200), math.random(200),0))
		ability:OnSpellStart()
		ability:StartCooldown(ability:GetCooldown(-1))
	end
end


function IncreaseCD(keys)
	local ability = keys.ability
	local usedability = keys.event_ability
	
	local cdreduction = 2
	Timers:CreateTimer(0.01,function()
		if not usedability:IsCooldownReady() then
			local cd = usedability:GetCooldownTimeRemaining()
			usedability:EndCooldown()
			usedability:StartCooldown(cd * cdreduction)
		else
			return 0.01
		end
	end)
end

function BashDamage(keys)
	local damage = keys.target:GetMaxHealth()*0.35
	if keys.caster:HasAbility("new_game_damage_increase") then
			damage = damage/10
	end
	ApplyDamage({ victim = keys.target, attacker = keys.caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = keys.ability })
end

function RootDamage(keys)
	local damage = keys.target:GetHealth()*0.15
	if keys.caster:HasAbility("new_game_damage_increase") then
			damage = damage/10
	end
	ApplyDamage({ victim = keys.target, attacker = keys.caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = keys.ability })
end

function ApplyPlague(keys)
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local currstack = target:GetModifierStackCount(keys.counter, caster)
	target:RemoveModifierByName(keys.counter)
	ability:ApplyDataDrivenModifier(caster,target, keys.modifier, {duration = 4})
	ability:ApplyDataDrivenModifier(caster,target, keys.counter, {duration = 4})
	target:SetModifierStackCount(keys.counter, caster, currstack + 1)
end

function DecreasePlague(keys)
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local currstack = target:GetModifierStackCount(keys.counter, caster)
	target:SetModifierStackCount(keys.counter, caster, currstack - 1)
end


function PlagueDamage(keys)
	local damage = keys.target:GetHealth()*0.03
	if keys.caster:HasAbility("new_game_damage_increase") then
			damage = damage/10
	end
	ApplyDamage({ victim = keys.target, attacker = keys.caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = keys.ability })
end

function PiercingDamage(keys)
	local damage = keys.damage*50/(GameRules._roundnumber*25)
	if keys.caster:HasAbility("new_game_damage_increase") then
			damage = damage/10
	end
	ApplyDamage({ victim = keys.target, attacker = keys.caster, damage = damage + keys.target:GetMaxHealth * 0.04, damage_type = DAMAGE_TYPE_PURE, ability = keys.ability })
end

function TestGravityFunc(keys)
    local targetPos = keys.target:GetAbsOrigin()
    local casterPos = keys.caster:GetAbsOrigin()
	if not keys.caster:IsAlive() then return end
    local direction = targetPos - casterPos
    local vec = direction:Normalized() * 2.5
	if direction:Length2D() <= 900 and direction:Length2D() >= 200 and keys.caster:IsAlive() then
		keys.target:SetAbsOrigin(targetPos - vec)
		ResolveNPCPositions(keys.target:GetAbsOrigin(), 100)
	else
		FindClearSpaceForUnit(target, targetPos, false)
	end
	ApplyDamage({ victim = keys.target, attacker = keys.caster, damage = math.floor(keys.caster:GetMaxHealth()*0.001*((900-direction:Length2D())/900)^1.25), damage_type = DAMAGE_TYPE_MAGICAL, ability = keys.ability })
end

function SweepingStrikes(keys)
	local caster = keys.caster
	local radius = caster:GetAttackRange() + caster:GetAttackRangeBuffer() + 100
	local counter = 3
	local units = FindUnitsInRadius(caster:GetTeam(),
                                  caster:GetAbsOrigin(),
                                  nil,
                                  radius,
                                  DOTA_UNIT_TARGET_TEAM_ENEMY,
                                  DOTA_UNIT_TARGET_ALL,
                                  DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                                  FIND_ANY_ORDER,
                                  false)
	for _, unit in pairs( units ) do
		if counter > 0 then
			caster:PerformAttack(unit, false, false, true, false, true)
			counter = counter - 1
		end
	end
end

function ArmorCheck(keys)
	local ability = keys.ability
	local caster = keys.caster
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), 
									caster:GetAbsOrigin(), 
									caster, 
									FIND_UNITS_EVERYWHERE,
									DOTA_UNIT_TARGET_TEAM_ENEMY,
                                    DOTA_UNIT_TARGET_HERO,
                                    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                                    FIND_ANY_ORDER,
                                    false)
	local totalarmor = 0
	for _,unit in pairs(enemies) do
		totalarmor = totalarmor + unit:GetPhysicalArmorValue()
	end
	ability.armor = totalarmor / #enemies
end

function ArmorDebuff(keys)
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local armordebuff = math.ceil(ability.armor * 0.04)
	ability:ApplyDataDrivenModifier(caster,target, keys.modifier, {duration = 10})
	ability:ApplyDataDrivenModifier(caster,target, keys.counter, {duration = 10})
	local currstack = target:GetModifierStackCount(keys.counter, caster)
	target:SetModifierStackCount(keys.counter,caster, currstack + 1)
	target:SetModifierStackCount(keys.modifier,caster, armordebuff * currstack)
end

function ArmorDebuffAura(keys)
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	if not ability.armor then
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), 
										caster:GetAbsOrigin(), 
										caster, 
										FIND_UNITS_EVERYWHERE,
										DOTA_UNIT_TARGET_TEAM_ENEMY,
										DOTA_UNIT_TARGET_HERO,
										DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
										FIND_ANY_ORDER,
										false)
		local totalarmor = 0
		for _,unit in pairs(enemies) do
			totalarmor = totalarmor + unit:GetPhysicalArmorValue()
		end
		ability.armor = totalarmor / #enemies
	end
	local armordebuff = ability.armor * 0.5
	ability:ApplyDataDrivenModifier(caster,target, keys.modifier, {})
	target:SetModifierStackCount(keys.modifier,caster, armordebuff)
end

function NimbleHealth( keys )
	local caster = keys.caster
	local ability = keys.ability

	ability.caster_hp_old = ability.caster_hp_old or caster:GetMaxHealth()
	ability.caster_hp = ability.caster_hp or caster:GetMaxHealth()

	ability.caster_hp_old = ability.caster_hp
	ability.caster_hp = caster:GetHealth()
end

function NimbleHeal( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster:SetHealth(ability.caster_hp_old)
end

function UnstableFunction(keys)
	local caster = keys.caster
	local ability = keys.ability
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), 
									caster:GetAbsOrigin(), 
									caster, 
									900,
									DOTA_UNIT_TARGET_TEAM_ENEMY,
                                    DOTA_UNIT_TARGET_ALL,
                                    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                                    FIND_ANY_ORDER,
                                    false)
	if not enemies then return end
	local totalhp = 0
	for _,unit in pairs(enemies) do
		totalhp = totalhp + unit:GetMaxHealth()
	end
	local averagehp = totalhp / #enemies
	local damage = averagehp
	if keys.caster:HasAbility("new_game_damage_increase") then
			damage = damage/10
	end
	for _,unit in pairs(enemies) do
		if RollPercentage(15) then
			local location = unit:GetAbsOrigin() + Vector(math.random(700),math.random(700),0)
			local rnd = math.random(100)
			if rnd > 33 and rnd < 66 then
				ability:ApplyAOE("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf",nil,location,250,damage*0.5,2, nil, 0)
			elseif rnd < 33 then
				ability:ApplyAOE("particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf",nil,location,200,damage*0.3,2, "modifier_elite_unstable_stun", 2)
			else
				ability:ApplyAOE("particles/econ/items/kunkka/kunkka_weapon_whaleblade/kunkka_spell_torrent_splash_whaleblade.vpcf",nil,location,350,damage*0.35,2, "modifier_elite_unstable_slow", 4)
			end
		end
	end
end
	