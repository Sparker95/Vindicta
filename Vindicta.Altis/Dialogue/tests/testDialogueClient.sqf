#include "..\common.hpp"

pr _instance = CALLSM0("DialogueClient", "getInstance");

pr _text = selectRandom
[
	"Some usage of this information may constitute a violation of the rights of Bohemia Interactive and is in no way endorsed or recommended by Bohemia Interactive.",
	"Triggered when mission ends, either using trigger of type End, endMission command, BIS_fnc_endMission function or ENDMISSION cheat. ",
	//"Triggered when mission is loaded from save. ",
	"Triggered when map is opened or closed either by user action or script command openMap. "
];

_text = _text;
pr _object = cursorObject;
if (isNull _object) then {
	_object = player;
};
CALLM3(_instance, "_createLineControl", _text, LINE_TYPE_SENTENCE, _object);
CALLM1(_instance, "_createPointerControl", _object);