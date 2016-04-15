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

Update()

function Update(){
$.Schedule(1, Update);
CustomNetTables.SubscribeNetTableListener
	key = "NG"
	data = CustomNetTables.GetTableValue( "New_Game_plus", "NG")
	if (typeof data != 'undefined') {
	if (data.NG == 1){ $("#demon_button").visible = true;}
	}
}


$("#demon_button").visible = false;
$("#hide_shop").visible = false;
$("#demon_shop").visible = false;

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


