

GameEvents.Subscribe( "UpdateLife", life)
GameEvents.Subscribe( "UpdateRound", PogressiveRound)
GameEvents.Subscribe( "UpdateTimeLeft", updateTime)



function life(msg)
{
	$("#Life").text = msg.life + " Retries";
}


function updateTime(msg){
	
	var time = Math.round(msg.Time)
	$("#Rounds").text ="Round " + msg.nextRound + " in "+ time +" Seconds";
	$("#RoundsTitle").text = "";
}


function PogressiveRound(msg){
	$("#BossRound").visible = true

	var wordToWrite = "Round " + msg.roundNumber + " : "
	var actualWord = ""
	UpdateWord()

	function UpdateWord(){

		actualWord = actualWord + wordToWrite[actualWord.length]
		$("#Rounds").text = actualWord;

		if (actualWord.length < wordToWrite.length){
			$.Schedule(0.1,UpdateWord);
		}
	}

	$.Schedule( (0.1+wordToWrite.length*0.1),UpdateWordTitle);

	var titleToWrite = $.Localize(msg.roundTitle)
	var actualTitle = ""

	function UpdateWordTitle(){

		actualTitle = actualTitle + titleToWrite[actualTitle.length]
		$("#RoundsTitle").text = actualTitle;

		if (actualTitle.length < titleToWrite.length){
			$.Schedule(0.06,UpdateWordTitle);
		}
	}
}





