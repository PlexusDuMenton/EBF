function ReflectDamage(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local ability = keys.ability
	local damageTaken = keys.damage
	local reflect_pct = ability:GetSpecialValueFor("reflect_pct")/100
	
	-- Check if it's not already been hit
	if not attacker:IsMagicImmune() then
		attacker:SetHealth( attacker:GetHealth() - damageTaken*reflect_pct )
		if attacker:GetHealth() < 1 then
			attacker:SetHealth(1)
			attacker:ForceKill(true)
		end
		caster:SetHealth( caster:GetHealth() + damageTaken*reflect_pct )
	end
end