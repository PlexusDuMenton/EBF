

if bossManager == nil then
	bossManager = class({})
end


function bossManager:Init(MainClass)

	self.MainClass = MainClass

end

function bossManager:EHPFix(EHP_GOAL,HP) --you enter the current HP
  local Multiplier = (EHP_GOAL/HP)
	return Multiplier
end

LinkLuaModifier( "bossHealthRescale", "modifier/bossHealthRescale.lua", LUA_MODIFIER_MOTION_NONE )


function bossManager:NewGamePlusBoss(spawnedUnit)

  if self.MainClass._NewGamePlus == true then
    local Number_Round = self.MainClass._nRoundNumber
    spawnedUnit.MaxEHP = (300000 + (spawnedUnit.MaxEHP*Number_Round^1.5) )

    spawnedUnit:SetBaseDamageMin((spawnedUnit:GetBaseDamageMin()+2000000)*(Number_Round^0.70 +2) )
    spawnedUnit:SetBaseDamageMax((spawnedUnit:GetBaseDamageMax()+3000000)*(Number_Round^0.80 +2) )
    spawnedUnit:SetPhysicalArmorBaseValue((spawnedUnit:GetPhysicalArmorBaseValue() + 2500)*(Number_Round^0.75+1))
    if spawnedUnit:GetBaseMagicalResistanceValue() < (100 - (36-Number_Round)^0.7) then
      if spawnedUnit:GetUnitName() ~= "npc_dota_boss33_a_vh" and spawnedUnit:GetUnitName() ~= "npc_dota_boss33_a_h" and spawnedUnit:GetUnitName() ~= "npc_dota_boss33_a" then
        spawnedUnit:SetBaseMagicalResistanceValue(100 - (36-Number_Round)^0.7)
      end
    end
  end
end


function bossManager:onBossSpawn(spawnedUnit)

	if spawnedUnit:IsCreature() then
		local difficulty_multiplier = (PlayerResource:GetTeamPlayerCount() / 7)^0.2
		spawnedUnit.MaxEHP = difficulty_multiplier*spawnedUnit:GetMaxHealth()
		spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())
		spawnedUnit:SetBaseDamageMin(difficulty_multiplier*spawnedUnit:GetBaseDamageMin())
		spawnedUnit:SetBaseDamageMax(difficulty_multiplier*spawnedUnit:GetBaseDamageMax())
		spawnedUnit:SetPhysicalArmorBaseValue(difficulty_multiplier*spawnedUnit:GetPhysicalArmorBaseValue())
    	self:NewGamePlusBoss(spawnedUnit)

    	if GetMapName() == "epic_boss_fight_boss_master" then 
			if spawnedUnit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
				Timers:CreateTimer(0.03,function()
					spawnedUnit:SetOwner(PlayerResource:GetSelectedHeroEntity(self.boss_master_id))
					spawnedUnit:SetControllableByPlayer(self.boss_master_id,true)

				end)
			end
		end
		spawnedUnit.EHP_MULT = 1 
		Timers:CreateTimer( 0.1, function()
		  	if spawnedUnit.MaxEHP > 200000 then
				spawnedUnit:SetMaxHealth(200000)
				spawnedUnit:SetHealth(200000)
				local EHP_MULT = self:EHPFix(spawnedUnit.MaxEHP,200000)
				spawnedUnit.EHP_MULT = EHP_MULT
				spawnedUnit:SetBaseHealthRegen(spawnedUnit:GetBaseHealthRegen()/EHP_MULT)
		    	spawnedUnit:AddNewModifier(spawnedUnit, spawnedUnit, "bossHealthRescale",{})
			else
				spawnedUnit.EHP_MULT = 1
			end
		end)
	end
end



