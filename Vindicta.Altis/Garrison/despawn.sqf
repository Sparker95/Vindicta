#include "common.hpp"

// Class: Garrison
/*
Method: spawn
Despawns all groups and units in this garrison.

Threading: should be called through postMethod (see <MessageReceiverEx>)

Returns: nil
*/

#define pr private

params [P_THISOBJECT];

OOP_INFO_0("DESPAWN");

ASSERT_THREAD(_thisObject);

if(T_CALLM("isDestroyed", [])) exitWith {
	OOP_WARNING_MSG("Attempted to call function on destroyed garrison %1", [_thisObject]);
	DUMP_CALLSTACK;
};

private _spawned = T_GETV("spawned");
if (!_spawned) exitWith {
	OOP_WARNING_0("Already despawned");
	//DUMP_CALLSTACK;
};

// Reset spawned flag
T_SETV("spawned", false);

private _units = T_GETV("units");
private _groups = (T_GETV("groups"));
private _groupsCopy = +_groups;

// Stop group AIs, but don't delete them
/*
// Very weird, somehow it hangs here, will have to investigate more later.
OOP_INFO_1("Stopping AI of groups: %1", _groups);
private _i = 0;
while {_i < count _groups} do
{
	private _group = _groups select _i;
	private _AI = CALLM0(_group, "getAI");
	if (!IS_NULL_OBJECT(_AI)) then {
		CALLM2(gMessageLoopGroupManager, "postMethodSync", "stopAIobject", [_AI]);
	};
};
*/

// Despawn groups, delete empty groups
OOP_INFO_1("Despawning groups: %1", _groups);
private _i = 0;
while {_i < count _groups} do
{
	private _group = _groups select _i;
	CALLM0(_group, "despawn");
	
	pr _units = CALLM0(_group, "getUnits");
	if (count _units == 0) then {
		_groups deleteAt _i;
		DELETE(_group);
	} else {
		_i = _i + 1;
	};
};


// Despawn single units
private _ungroupedUnits = _units select {
	CALLM0(_x, "getGroup") == ""
};

OOP_INFO_1("Despawning ungrouped units: %1", _ungroupedUnits);
{
	private _unit = _x;
	CALLM0(_unit, "despawn");
} forEach _ungroupedUnits;

// Call onGarrisonDespawned
pr _AI = T_GETV("AI");
pr _action = CALLM0(_AI, "getCurrentAction");
if (_action != "") then {
	_action = CALLM0(_action, "getFrontSubaction");
	if (_action != "") then {
		OOP_INFO_1("Calling %1.onGarrisonDespawned", _action);
		CALLM0(_action, "onGarrisonDespawned");
	} else {
		OOP_INFO_0("DESPAWN: no current action");
	};
};

// Update process interval of AI
//CALLM1(_AI, "setProcessInterval", AI_GARRISON_PROCESS_INTERVAL_DESPAWNED);

// Change process category if active
if (T_GETV("active")) then {
	CALLM2(T_CALLM0("getMessageLoop"), "addProcessCategoryObject", "AIGarrisonDespawned", _AI);
};

0