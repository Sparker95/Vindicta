#include "..\OOP_Light\OOP_Light.h"

// Client side only
if (!hasInterface) exitWith {};
params ["_target", "_caller", "_actionId", "_arguments"];

[[_target, _actionId], {
	if (!hasInterface) exitWith {};
	params ["_target", "_actionId"];
	_target removeAction _actionId;
}] remoteExec ["call", -2, false];


[[_caller, _target], {
	params ["_caller", "_target"];
	
	private _maybe = random 2;
	if (_maybe > 1) then {
		CALLM1(SideStatWest, "incrementHumanResourcesBy", 1);
		gSideStatWestHR = CALLM0(SideStatWest, "getHumanResources");
		publicVariable "gSideStatWestHR";
		
		[ "", {hint "ok cunt ill fight for ya";}] remoteExec ["spawn", owner _caller, false];
	} else {
		[ "", {hint "fuck ya mate";}] remoteExec ["spawn", owner _caller, false];
	}

}] remoteExec ["spawn", 2, false];

