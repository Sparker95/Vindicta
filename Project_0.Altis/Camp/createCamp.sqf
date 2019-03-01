#include "..\OOP_Light\OOP_Light.h"

params ["_target"];

private _allLocations = GETSV("Location", "all");
private _isPosAllowed = true;
private _pos = getPosWorld _target;

{
	private _locPos = CALLM0(_x, "getPos");
	private _type = CALLM0(_x, "getType");
	private _dist = _pos distance _locPos;
	if (_dist < 100) exitWith {_isPosAllowed = false;};
	// if (_dist < 3000 && _type == "camp") exitWith {_isPosAllowed = false;};
} forEach _allLocations;

if (_isPosAllowed) then {
	if (isServer) then {
		NEW_PUBLIC("Camp", [_pos]);
	} else {
		REMOTE_EXEC_STATIC_METHOD("Camp", "newStatic", [_pos], 2, false);
	}
} else {
	hint "Too close from another Location (need 100m from any location)";
};
