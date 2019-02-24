#include "..\..\OOP_Light\OOP_Light.h"
#include "..\Action\Action.hpp"

/*
Class: Action.ActionCompositeParallel
NYI

Not really sure if it's needed.

Parallel action evaluates all subactions at once.

It returns:
COMPLETED if all subactions are in COMPLETED state
FAILED if any subaction has failed
INACTIVE right after this action creation
ACTIVE otherwise

Author: Sparker 05.08.2018
*/

CLASS("ActionCompositeParallel", "ActionComposite")
	
	// ----------------------------------------------------------------------
	// |                            P R O C E S S                           |
	// |                                                                    |
	// | By default we just process all subactions in parallel way            |
	// ----------------------------------------------------------------------
	
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		private _state = CALLM(_thisObject, "processSubactions", []);
		SETV(_thisObject, "state", _state);
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    P R O C E S S   S U B G O A L S                 |
	// ----------------------------------------------------------------------
	
	METHOD("processSubactions") {
		params [["_thisObject", "", [""]]];
		private _subactions = GETV(_thisObject, "subactions");
		
		private _subactionsStates = _subactions apply { CALLM(_x, "process", []) };
		
		// Are all subactions completed?
		private _countCompleted = {_x == ACTION_STATE_COMPLETED} count _subactionsStates;
		if (_countCompleted == count _subactions) exitWith { ACTION_STATE_COMPLETED };
		
		// Has any subaction failed?
		private _countFailed = {_x == ACTION_STATE_FAILED} count _subactionsStates;
		if (_countFailed > 0) exitWith { ACTION_STATE_FAILED };
		
		// Otherwise return ACTIVE
		ACTION_STATE_ACTIVE
	} ENDMETHOD;

ENDCLASS;