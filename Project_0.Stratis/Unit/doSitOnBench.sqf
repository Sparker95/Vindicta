/*
Makes this unit sit on bench
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Unit\Unit.hpp"
#include "..\Message\Message.hpp"
#include "..\MessageTypes.hpp"

params [["_thisObject", "", [""]], ["_bench", "", [""]], ["_pointID", 0, [0]] ];

// Get information about this point
private _args = [_thisObject, _pointID];
private _pointData = CALLM(_bench, "getPointData", _args);
if (count _pointData > 0) then {
	// Get variables
	_pointData params ["_offset", "_animation", "_dir"];
	private _data = GETV(_thisObject, "data");
	private _objectHandle = _data select UNIT_DATA_ID_OBJECT_HANDLE;
	private _benchObject = CALLM(_bench, "getObject", []);
	
	// Perform actions
	_objectHandle disableCollisionWith _benchObject;
	_objectHandle attachTo [_benchObject, _offset];
	detach _objectHandle;
	_objectHandle setDir _dir; 
	_objectHandle switchMove _animation;
	_objectHandle disableAI "MOVE";
	_objectHandle disableAI "ANIM";
	
	// Spawn a script to make the unit jump on his feet quickly
	private _hScript = [_thisObject, _objectHandle, _bench, _pointID] spawn { 
		params ["_unit", "_objectHandle", "_bench", "_pointID"];
		waitUntil {sleep 0.05; (behaviour _objectHandle) == "COMBAT" || (!alive _objectHandle) };
		
		// Are you still OK?		
		if (alive _objectHandle) then { CALLM(_unit, "doGetUpFromBench", []); };		
		
		// Send a message to the goal of this unit
		private _data = GETV(_unit, "data");
		private _goal = _data select UNIT_DATA_ID_GOAL;
		private _msg = MESSAGE_NEW();
		_msg set [MESSAGE_ID_DESTINATION, _goal];
		_msg set [MESSAGE_ID_TYPE, GOAL_MESSAGE_ANIMATION_INTERRUPTED];
		CALLM(_goal, "postMessage", [_msg]);
	 };
	
	_objectHandle setVariable ["unit_hScriptBench", _hScript];
	
	true // Sit successfull
} else {
	false // Failed to sit here
};