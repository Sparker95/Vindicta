#include "..\common.hpp"

private _talker = cursorObject;
if (isNull _talker) then {_obj = player;};

pr _text = selectRandom
[
	"Some usage of this information may constitute a violation of the rights of Bohemia Interactive and is in no way endorsed or recommended by Bohemia Interactive.",
	"Triggered when mission ends, either using trigger of type End, endMission command, BIS_fnc_endMission function or ENDMISSION cheat. ",
	//"Triggered when mission is loaded from save. ",
	"Triggered when map is opened or closed either by user action or script command openMap. "
];

CALLSM3("Dialogue", "objectSaySentence", "", _talker, _text);