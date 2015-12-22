GameEvents.Subscribe( "Update_Asura_Core", update_core)
GameEvents.Subscribe( "Display_Asura_Core", display_core)
GameEvents.Subscribe( "Refresh_HUD", refresh_core)
$("#Asura_Core").visible = false;
function update_core(arg)
	{
		$("#core_number").text = arg.core;
	}
function display_core(arg)
	{
		$("#Asura_Core").visible = true;
	}
function refresh_core(arg)
	{
		$("#Asura_Core").visible =false;
	}
function tell_core()
	{
		var ID = Players.GetLocalPlayer()
		GameEvents.SendCustomGameEventToServer( "Tell_Core", { pID: ID} );
	}