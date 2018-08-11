/*
A composite goal for a unit to sit on a bench.
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Goal\Goal.hpp"

CLASS("GoalUnitMoveInf", "GoalCompositeSerial")

	VARIABLE("bench"); // Bench is derived from AnimObject
	VARIABLE("pointID"); // The ID of the point where the unit is going to sit at
	VARIABLE("sitDuration"); // How many seconds the bot will be sitting on the bench until the task is completed
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_entity", "", [""]], ["_bench", [], [[]]], ["_sitDuration", 0, [0]]];
		SETV(_thisObject, "bench", _bench);
		SETV(_thisObject, "sitDuration", _sitTime);
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
		private _bench = GETV(_thisObject, "bench");
		private _pointIDAndPos = CALLM(_bench, "getFreePoint", []);
		if (count _pointIDAndPos > 0) then {
			_pointIDAndPos params ["_pointID", "_pos"];
			SETV(_thisObject, "pointID", _pointID);
			
			// Add a goal to sit on the bench
			
			
			// Add a goal for the unit to move to the bench
			private _goalMove = NEW("GoalUnitMoveInf", [_pos]);
			CALLM(_thisObject, "addSubgoal", [_goalMove]);
			
			SETV(_entity, "state", GOAL_STATE_ACTIVE);
		} else {
			// The bench is already occupied!
			SETV(_thisObject, "state", GOAL_STATE_FAILED);
		};		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                          P R O C E S S                             |
	// ----------------------------------------------------------------------

	METHOD("process") {
		params [["_thisObject", "", [""]]];
		CALLM(_thisObject, "activateIfInactive", []);
		
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