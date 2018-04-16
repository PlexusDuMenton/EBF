
function No()
{
	var ID = Players.GetLocalPlayer()
	GameEvents.SendCustomGameEventToServer( "Vote_NG", { pID: ID,vote: false} );
}

function Yes()
{
	var ID = Players.GetLocalPlayer()
	GameEvents.SendCustomGameEventToServer( "Vote_NG", { pID: ID,vote: true} );
}

GameEvents.Subscribe( "Display_Vote", open)
GameEvents.Subscribe( "Close_Vote", close)
GameEvents.Subscribe( "refresh_time", refresh)
$("#Vote").visible = false;
function open()
{
	$("#Vote").visible = true;
}
function close()
{
	$("#Vote").visible = false;
}
function refresh(arg)
{
	$("#time_nb").text = arg.time;
}

