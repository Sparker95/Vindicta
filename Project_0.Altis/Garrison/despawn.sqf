#include "common.hpp"
#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"

// Class: Garrison
/*
Method: spawn
Despawns all groups and units in this garrison.

Threading: should be called through postMethod (see <MessageReceiverEx>)

Returns: nil
*/

#define pr private

params [["_thisObject", "", [""]]];

private _spawned = GET_VAR(_thisObject, "spawned");

OOP_INFO_0("DESPAWN");

if (!_spawned) exitWith {
	OOP_ERROR_0("Already despawned");
};

// Reset spawned flag
SET_VAR(_thisObject, "spawned", false);

private _units = GET_VAR(_thisObject, "units");
private _groups = (GET_VAR(_thisObject, "groups"));
private _groupsCopy = +_groups;

// Despawn groups, delete empty groups
OOP_INFO_1("Despawning groups: %1", _groups);
private _i = 0;
while {_i < count _groups} do
{
	private _group = _groups select _i;
	CALLM(_group, "despawn", []);
	
	pr _units = CALLM0(_group, "getUnits");
	if (count _units == 0) then {
		_groups deleteAt _i;
		DELETE(_group);
	} else {
		_i = _i + 1;
	};
};


// Despawn single units
{
	private _unit = _x;
	if (CALL_METHOD(_x, "getGroup", []) == "") then {
		CALL_METHOD(_unit, "despawn", []);
	};
} forEach _units;

// Call onGarrisonDespawned
pr _action = CALLM0(T_GETV("AI"), "getCurrentAction");
_action = CALLM0(_action, "getFrontSubaction");
if (_action != "") then {
	CALLM0(_action, "onGarrisonDespawned");
};