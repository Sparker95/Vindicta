#include "..\OOP_Light\OOP_Light.h"

params ["_target", "_caller", "_actionId", "_arguments"];

private _maybe = random 2;
if (_maybe > 1) then {
	CALLM1(gSideStatWest, "incrementHumanResourcesBy", 1);
	hint "ok cunt ill fight for ya";
} else {
	hint "fuck ya mate";
}

