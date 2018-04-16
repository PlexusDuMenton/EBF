var ID = Players.GetLocalPlayer()
var PlayerEntityIndex = Players.GetPlayerHeroEntityIndex(ID)
var team = Entities.GetTeamNumber( PlayerEntityIndex )
$("#hp_bar_general").visible = false;
$("#hp_bar_shield").visible = false;
		var HB_State = true;
		$('#'+"option_close").visible = false; 
		$('#'+"option_general").visible = false; 

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
				$("#hp_bar_general").visible = true;
				$('#'+"text_HB").text = "Disable Custom HealthBar";
				var iPlayerID = Players.GetLocalPlayer();
				GameEvents.SendCustomGameEventToServer( "Health_Bar_Command", { Enabled: true , pID: iPlayerID} );
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
	
	function update_hp_bar(arg)
	{
		$("#hp_bar_parent_health").style.clip = "rect( 0% ," + ((arg.current_life_disp/arg.total_life_disp)*96.13+1.83) + "%" + ", 100% ,0% )";
		$("#hp_bar_current").text = arg.current_life;
		$("#hp_bar_name").text = $.Localize("#"+arg.name)
	}
		
		