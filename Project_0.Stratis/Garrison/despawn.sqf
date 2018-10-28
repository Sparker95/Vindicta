/*
Despawns the whole garrison
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"

params [["_thisObject", "", [""]]];

private _spawned = GET_VAR(_thisObject, "spawned");

if (!_spawned) exitWith { diag_log format ["[Garrison::despawn] Error: Can't despawn a garrison which is not spawned: %1",
	GET_VAR(_thisObject, "debugName")]; };

// Reset spawned flag
SET_VAR(_thisObject, "spawned", false);

// Delete the action object
private _action = GETV(_thisObject, "action");
if (_action != "") then {
	private _msg = MESSAGE_NEW();
	_msg set [MESSAGE_ID_DESTINATION, _action];
	_msg set [MESSAGE_ID_TYPE, ACTION_MESSAGE_DELETE];
	private _msgID = CALLM(_action, "postMessage", [_msg]);
	CALLM(_action, "waitUntilMessageDone", [_msgID]);
	SETV(_thisObject, "action", "");
};

private _units = GET_VAR(_thisObject, "units");
private _groups = GET_VAR(_thisObject, "groups");

// Despawn groups
{
	private _group = _x;
	private _groupUnits = CALL_METHOD(_group, "getUnits", []);
	{
		private _unit = _x;
		CALL_METHOD(_unit, "despawn", []);
	} forEach _groupUnits;
} forEach _groups;

// Despawn single units
{
	private _unit = _x;
	if (CALL_METHOD(_x, "getGroup", []) == "") then {
		CALL_METHOD(_unit, "despawn", []);
	};
} forEach _units;