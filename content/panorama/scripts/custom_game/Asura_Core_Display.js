GameEvents.Subscribe( "Update_Asura_Core", update_core)
GameEvents.Subscribe( "Display_Asura_Core", display_core)
GameEvents.Subscribe( "Display_Shop", display_core)
var visible = false;
$("#Asura_Core").visible = visible;
function update_core(arg)
	{
		$("#core_number").text = arg.core;
		if (!visible)
		{
			display_core();
		}
	}
function display_core()
	{
		visible = true;
		$("#Asura_Core").visible = true;
	}
function tell_core()
	{
		var ID = Players.GetLocalPlayer()
		GameEvents.SendCustomGameEventToServer( "Tell_Core", { pID: ID} );
	}