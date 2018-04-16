var ID = Players.GetLocalPlayer()
var PlayerEntityIndex = Players.GetPlayerHeroEntityIndex(ID)
var team = Entities.GetTeamNumber( PlayerEntityIndex )
$('#'+"midas_gold").visible = false;
$('#'+"midas_gold_open").visible = false;
$('#'+"midas_gold_close").visible = false;
$.Msg('Team ID',team)
GameEvents.Subscribe( "create_midas_display", create_gold_display)
	function create_gold_display()
	{
		if (team < 3)
		{
			$('#'+"midas_gold_close").visible = true;
			$('#'+"midas_gold").visible = true;
		}
	}
GameEvents.Subscribe( "Update_Midas_Gold", update_gold)
	function open_gold()
	{
		$('#'+"midas_gold_open").visible = false;
		$('#'+"midas_gold_close").visible = true;
		$('#'+"midas_gold").visible = true;
	}
	
	function close_gold()
	{
		$('#'+"midas_gold_open").visible = true;
		$('#'+"midas_gold_close").visible = false;
		$('#'+"midas_gold").visible = false;
	}
	
	function update_gold(values)
	{
		$.Msg('update_gold_earned : ',values.gold);
		$('#'+"midas_gold_earned").text = values.gold;
	}

		

