var ID = Players.GetLocalPlayer()
var PlayerEntityIndex = Players.GetPlayerHeroEntityIndex(ID)
var team = Entities.GetTeamNumber( PlayerEntityIndex )
$("#hp_bar_general").visible = false;
$("#hp_bar_shield").visible = false;
$("#DPS_main").visible = false;
		var HB_State = true;
		var dps_State = false;
		$('#'+"option_unmute_sound").visible = false; 
		$('#'+"option_close").visible = false; 
		$('#'+"option_general").visible = false; 

		function mute_sound()
		{
			$("#option_mute_sound").visible = false;
			$("#option_unmute_sound").visible = true;
			var iPlayerID = Players.GetLocalPlayer();
			$.Msg('Player ID mute ');
			GameEvents.SendCustomGameEventToServer( "mute_sound", { pID: iPlayerID} );
		}
		
		function unmute_sound()
		{
			$("#option_mute_sound").visible = true;
			$("#option_unmute_sound").visible = false;
			var iPlayerID = Players.GetLocalPlayer();
			$.Msg('Player ID unmute ');
			GameEvents.SendCustomGameEventToServer( "unmute_sound", { pID: iPlayerID} );
		}
		function switch_HB()
		{
			if (HB_State)
			{
				HB_State = false;
				$("#hp_bar_general").visible = false;
				$('#'+"text_HB").text = "Enable Custom HealthBar";
				var iPlayerID = Players.GetLocalPlayer();
				GameEvents.SendCustomGameEventToServer( "Health_Bar_Command", { Enabled: false , pID: iPlayerID} );
			}
			else
			{
				HB_State = true;
				//$("#hp_bar_general").visible = true;
				$('#'+"text_HB").text = "Disable Custom HealthBar";
				var iPlayerID = Players.GetLocalPlayer();
				GameEvents.SendCustomGameEventToServer( "Health_Bar_Command", { Enabled: true , pID: iPlayerID} );
			}
		}
		function switch_dps()
		{
			if (dps_State)
			{
				dps_State = false;
				$("#DPS_main").visible = false;
				$('#'+"text_DPS").text = "Enable DPS Meter";
			}
			else
			{
				dps_State = true;
				$("#DPS_main").visible = true;
				$('#'+"text_DPS").text = "Disable DPS Meter";
			}
		}
		function open_option()
		{
			$("#option_general").visible = true;
			$("#option_close").visible = true;
			$("#option_open").visible = false;
		}
		function close_option()
		{
			$("#option_general").visible = false;
			$("#option_close").visible = false;
			$("#option_open").visible = true;
		}


GameEvents.Subscribe( "Update_Health_Bar", update_hp_bar)
GameEvents.Subscribe( "Update_mana_Bar", update_mana_bar)
GameEvents.Subscribe( "Close_Health_Bar", close_HB)
GameEvents.Subscribe( "Open_Health_Bar", open_HB)
GameEvents.Subscribe( "disactivate_shield", desactivate_shield)
GameEvents.Subscribe( "activate_shield", activate_shield)
	function close_HB()
	{
		if (team < 3)
		{
			$("#hp_bar_general").visible = false;
		}
	}
	function open_HB()
	{
		if (team < 3)
			{
				$("#hp_bar_general").visible = true;
			}
	}

	function desactivate_shield()
	{
		$("#hp_bar_shield").visible = false;
	}
	
	function activate_shield()
	{
		$("#hp_bar_shield").visible = true;
	}
	
	function update_mana_bar(arg)
	{
		$("#hp_bar_parent_mana").style.clip = "rect( 0% ," + ((arg.current_mana/arg.total_mana)*63.1+27.0) + "%" + ", 100% ,0% )";
	}
	function update_hp_bar(arg)
	{
		$("#hp_bar_parent_health").style.clip = "rect( 0% ," + ((arg.current_life_disp/arg.total_life_disp)*77.3+22.7) + "%" + ", 100% ,0% )";
		$("#hp_bar_current").text = arg.current_life;
		$("#hp_bar_total").text = arg.total_life;
		$("#hp_bar_name").text = "#"+arg.name;
	}
GameEvents.Subscribe( "Update_Damage", update_damage)
GameEvents.Subscribe( "Update_DPS", update_dps)
GameEvents.Subscribe( "Update_Damage_Team", update_damage_team)
	function update_damage(arg)
	{
		$("#damage").text = arg.damage;
	}
	function update_dps(arg)
	{
		$("#DPS").text = arg.dps;
	}
	function update_damage_team(arg)
	{
		$("#TD").text = arg.team;
	}
		
		