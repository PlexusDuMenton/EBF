--every function that communicate with panorama

if panoramaBridge == nil then
	panoramaBridge = class({})
end


function panoramaBridge:Init()
  GameRules:GetGameModeEntity():SetThink( "Update_Health_Bar", self, 0.09 )
end

function panoramaBridge:Update_Health_Bar()
		local higgest_ennemy_hp = 0
		local biggest_ennemy = nil
		for _,unit in pairs ( Entities:FindAllByName( "npc_dota_creature")) do
			if unit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
				if unit:GetMaxHealth()*unit.EHP_MULT > higgest_ennemy_hp and unit:IsAlive() then
					biggest_ennemy = unit
					higgest_ennemy_hp = unit:GetMaxHealth()*unit.EHP_MULT
				end
			end
		end
		if self.Last_Target_HB ~= biggest_ennemy and biggest_ennemy ~= nil then
			if self.Last_Target_HB ~= nil then
				ParticleManager:DestroyParticle(self.Last_Target_HB.HB_particle, false)
			end
			self.Last_Target_HB = biggest_ennemy
			self.Last_Target_HB.HB_particle = ParticleManager:CreateParticle("particles/health_bar_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW   , self.Last_Target_HB)
            ParticleManager:SetParticleControl(self.Last_Target_HB.HB_particle, 0, self.Last_Target_HB:GetAbsOrigin())
            ParticleManager:SetParticleControl(self.Last_Target_HB.HB_particle, 1, self.Last_Target_HB:GetAbsOrigin())
		end
		Timers:CreateTimer(0.1,function()
			if biggest_ennemy ~= nil and not biggest_ennemy:IsNull() and biggest_ennemy:IsAlive() then
				local table_arg = {}

				table_arg.total_life = set_comma_thousand(biggest_ennemy:GetMaxHealth()*biggest_ennemy.EHP_MULT)
				table_arg.current_life = set_comma_thousand(biggest_ennemy:GetHealth()*biggest_ennemy.EHP_MULT)
				table_arg.total_mana = biggest_ennemy:GetMaxMana()
				table_arg.current_mana = biggest_ennemy:GetMana()

				table_arg.total_life_disp = biggest_ennemy:GetMaxHealth()*biggest_ennemy.EHP_MULT
				table_arg.current_life_disp = biggest_ennemy:GetHealth()*biggest_ennemy.EHP_MULT

				table_arg.name = biggest_ennemy:GetUnitName()

				if self.Last_HP_Display ~= table_arg.current_life then
					self.Last_HP_Display = table_arg.current_life

					CustomGameEventManager:Send_ServerToAllClients("Update_Health_Bar", table_arg)
				end
				if table_arg.total_mana ~= 0 then
					CustomGameEventManager:Send_ServerToAllClients("Update_mana_Bar", table_arg)
				end
				if self.Shield == false and biggest_ennemy.have_shield == true then
					self.Shield = true
					CustomGameEventManager:Send_ServerToAllClients("activate_shield", {})
				elseif	self.Shield == true and biggest_ennemy.have_shield ~= true then
					self.Shield = false
					CustomGameEventManager:Send_ServerToAllClients("disactivate_shield", {})
				end
				for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
					if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
						if PlayerResource:HasSelectedHero( nPlayerID ) then
							local player = PlayerResource:GetPlayer(nPlayerID)
							if player.HB == true and player.Health_Bar_Open == false then
								player.Health_Bar_Open = true
								CustomGameEventManager:Send_ServerToPlayer(player,"Open_Health_Bar", {})
							end
						end
					end
				end
			else
				for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
					if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
						if PlayerResource:HasSelectedHero( nPlayerID ) then
							local player = PlayerResource:GetPlayer(nPlayerID)
							if player.HB == true and player.Health_Bar_Open == true then
								player.Health_Bar_Open = false
								CustomGameEventManager:Send_ServerToPlayer(player,"Close_Health_Bar", {})
							end
						end
					end
				end
			end
		end)

	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then		-- Safe guard catching any state that may exist beyond DOTA_GAMERULES_STATE_POST_GAME
		return nil
	end
	return 0.09
end







--utils

function comma_value(amount)
  local formatted = amount
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

---============================================================
-- rounds a number to the nearest decimal places
--
function round(val, decimal)
  if (decimal) then
    return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
  else
    return math.floor(val+0.5)
  end
end

--===================================================================
-- given a numeric value formats output with comma to separate thousands
-- and rounded to given decimal places
--
--
function set_comma_thousand(amount, decimal)
  local str_amount,  formatted, famount, remain

  decimal = decimal or 0  -- default 2 decimal places

  famount = math.abs(round(amount,decimal))
  famount = math.floor(famount)

  remain = round(math.abs(amount) - famount, decimal)

        -- comma to separate the thousands
  formatted = comma_value(famount)

        -- attach the decimal portion
  if (decimal > 0) then
    remain = string.sub(tostring(remain),3)
    formatted = formatted .. "." .. remain ..
                string.rep("0", decimal - string.len(remain))
  end
  return formatted
end
