function BuyItem(item,price,componement)
{
	var ID = Players.GetLocalPlayer()
	GameEvents.SendCustomGameEventToServer( "Demon_Shop", { pID: ID , item_name: item, price: price,item_recipe: componement } );
}

function BuyCore()
{
	var ID = Players.GetLocalPlayer()
	GameEvents.SendCustomGameEventToServer( "Asura_Core", { pID: ID} );
}

GameEvents.Subscribe( "Display_Shop", display_but)
$("#demon_button").visible = false;
$("#hide_shop").visible = false;
$("#demon_shop").visible = false;
function display_but(arg)
	{
		$("#demon_button").visible = true;
	}
function display_shop(arg)
	{
		$("#demon_shop").visible = true;
		$("#button_shop").visible = false;
		$("#hide_shop").visible = true;
		
	}
function hide_shop(arg)
	{
		$("#demon_shop").visible = false;
		$("#button_shop").visible = true;
		$("#hide_shop").visible = false;
	}



