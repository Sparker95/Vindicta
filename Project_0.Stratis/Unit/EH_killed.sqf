#include "..\OOP_Light\OOP_Light.h"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"
#include "Unit.hpp"

/*
Killed EH for units. Its main job is to send messages to objects. 
*/

#define pr private

params ["_objectHandle", "_killer", "_instigator", "_useEffects"];

// Is this object an instance of Unit class?
private _unit = CALL_STATIC_METHOD("Unit", "getUnitFromObjectHandle", [_objectHandle]);

diag_log format ["[Unit::EH_killed] Info: %1 %2", _unit, GETV(_unit, "data")];

if (_unit != "") then {
	// Since this code is run in event handler context, we can't delete the unit from the group and garrison directly.
	// Instead we must post message to group and garrison objects
	pr _data = GETV(_unit, "data");
	pr _group = _data select UNIT_DATA_ID_GROUP;
	pr _garrison = _data select UNIT_DATA_ID_GARRISON;
	if (_group != "") then { // Vehicles can have no group
		CALLM2(_group, "postMethodAsync", "handleUnitKilled", [_unit]);
	};
	if (_garrison != "") then {	// Sanity check	
		CALLM2(_garrison, "postMethodAsync", "handleUnitKilled", [_unit]);
	};
	
	// Delete the brain of this unit, if it exists
	pr _AI = _data select UNIT_DATA_ID_AI;
	if (_AI != "") then {
		pr _msg = MESSAGE_NEW();
		MESSAGE_SET_TYPE(_msg, AI_MESSAGE_DELETE);			
		pr _msgID = CALLM1(_AI, "postMessage", _msg);
		_data set [UNIT_DATA_ID_AI, ""];
	};
};