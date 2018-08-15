/*
A goal for an infantry unit to move to some place.
*/

#include "..\OOP_Light\OOP_Light.h"
#include "..\Goal\Goal.hpp"
#include "..\Message\Message.hpp"

CLASS("GoalUnitMoveInf", "Goal")

	VARIABLE("destPos");
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_entity", "", [""]], ["_destPos", [], [[]]]];
		SETV(_thisObject, "destPos", _destPos);
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
		private _destPos = GETV(_thisObject, "destPos");
		CALLM(_entity, "doMoveInf", [_destPos]);
		diag_log format ["===== Moving inf to pos: %1", _destPos];
		SETV(_thisObject, "state", GOAL_STATE_ACTIVE);
		GOAL_STATE_ACTIVE
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                          P R O C E S S                             |
	// ----------------------------------------------------------------------

	METHOD("process") {			
		params [["_thisObject", "", [""]]];
		CALLM(_thisObject, "activateIfInactive", []);		
		
		// Check if we have stuck
		
		// Check if we have arrived
		private _entity = GETV(_thisObject, "entity");
		private _destPos = GETV(_thisObject, "destPos");
		private _distance = CALLM(_entity, "distance", [_destPos]);
		if (_distance < 2.2) then { // Are we there yet???
			// We have arrived!
			SETV(_thisObject, "state", GOAL_STATE_COMPLETED);
			//CALLM(_thisObject, "terminate", []);
			
			GOAL_STATE_COMPLETED // return
		} else {
			GOAL_STATE_ACTIVE
		};
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                      H A N D L E   M E S S A G E                   |
	// |                                                                    |
	// ----------------------------------------------------------------------
	/*
	// If we don't redefine this method, the default one will be called anyway
	METHOD("handleMessage") {
		params [ ["_thisObject", "", [""]] , ["_msg", [], [[]]] ];
		//private _msgType = _msg select MESSAGE_ID_TYPE;
				
		// Pass message to handleMessage of the base class
		private _msgHandled = CALL_CLASS_METHOD("Goal", "handleMessage", [_msg]);
		_msgHandled
	} ENDMETHOD;
	*/
	
	// ----------------------------------------------------------------------
	// |                        T E R M I N A T E                           |
	// ----------------------------------------------------------------------

	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
		if (CALLM(_thisObject, "isActive", [])) then {
			private _entity = GETV(_thisObject, "entity");
			CALLM(_entity, "doStopInf");
		};
	} ENDMETHOD;

ENDCLASS;