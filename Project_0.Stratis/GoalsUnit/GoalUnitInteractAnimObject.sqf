/*
A composite goal for a unit to walk to an AnimObject and interact with it by playing an animation.

Author: Sparker 14.08.2018
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Goal\Goal.hpp"

CLASS("GoalUnitInteractAnimObject", "GoalCompositeSerial")

	VARIABLE("animObject"); // Bench is derived from AnimObject
	VARIABLE("pointID"); // The ID of the point where the unit is going to sit at
	VARIABLE("animDuration"); // How many seconds the bot will be sitting on the bench until the task is completed
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_entity", "", [""]], ["_animObject", "", [""]], ["_animDuration", 0, [0]]];
		SETV(_thisObject, "animObject", _animObject);
		SETV(_thisObject, "animDuration", _animDuration);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                        A C T I V A T E                             |
	// ----------------------------------------------------------------------

	METHOD("activate") {
		params [["_thisObject", "", [""]]];
		private _entity = GETV(_thisObject, "entity");
		private _animObject = GETV(_thisObject, "animObject");
		private _pointIDAndPosOffset = CALLM(_animObject, "getFreePoint", []);
		if (count _pointIDAndPosOffset > 0) then {
			_pointIDAndPosOffset params ["_pointID", "_posOffset"];
			SETV(_thisObject, "pointID", _pointID);
			
			// Add a goal to play the animation
			private _animDuration = GETV(_thisObject, "animDuration");
			private _args = [_entity, _animObject, _animDuration, _pointID];// ["_entity", "", [""]], ["_animObject", [], [[]]], ["_animDuration", 0, [0]], ["_pointID", 0, [0]]
			private _goalDoInteract = NEW("GoalUnitDoInteractAnimObject", _args);
			CALLM(_thisObject, "addSubgoal", [_goalDoInteract]);
			
			// Add a goal for the unit to move to the position
			// Convert the position from model coordinates to world coordinates
			private _animObjectHandle = CALLM(_animObject, "getObject", []);
			private _pos = _animObjectHandle modelToWorld _posOffset;
			//private _dir = _dir + (direction _animObjectHandle);
			private _posMoveTo = [_pos select 0, _pos select 1, _pos select 2 + 1];
			private _args = [_entity, _pos];
			private _goalMove = NEW("GoalUnitMoveInf", _args);
			CALLM(_thisObject, "addSubgoal", [_goalMove]);
			
			SETV(_thisObject, "state", GOAL_STATE_ACTIVE);
			GOAL_STATE_ACTIVE
		} else {
			// The bench is already occupied!
			SETV(_thisObject, "state", GOAL_STATE_FAILED);
			GOAL_STATE_FAILED
		};		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                          P R O C E S S                             |
	// ----------------------------------------------------------------------

	METHOD("process") {
		params [["_thisObject", "", [""]]];
		private _state = GETV(_thisObject, "state");
		if (_state != GOAL_STATE_FAILED) then {
			CALLM(_thisObject, "activateIfInactive", []);
			_state = CALLM(_thisObject, "processSubgoals", []);
		};
		
		SETV(_thisObject, "state", _state);
		_state
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                        T E R M I N A T E                           |
	// ----------------------------------------------------------------------

	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		private _entity = GETV(_thisObject, "entity");
		CALLM(_entity, "doStopInf");
	} ENDMETHOD;

ENDCLASS;