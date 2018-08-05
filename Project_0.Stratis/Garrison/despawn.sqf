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

// Delete the goal object
private _goal = GETV(_thisObject, "goal");
if (_goal != "") then {
	private _msg = MESSAGE_NEW();
	_msg set [MESSAGE_ID_DESTINATION, _goal];
	_msg set [MESSAGE_ID_TYPE, GOAL_MESSAGE_DELETE];
	private _msgID = CALLM(_goal, "postMessage", [_msg]);
	CALLM(_goal, "waitUntilMessageDone", [_msgID]);
	SETV(_thisObject, "goal", "");
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