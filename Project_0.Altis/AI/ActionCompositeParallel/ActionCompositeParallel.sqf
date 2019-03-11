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

#define pr private

CLASS("ActionCompositeParallel", "ActionComposite")
	
	// ----------------------------------------------------------------------
	// |                            P R O C E S S                           |
	// |                                                                    |
	// | By default we just process all subactions in parallel way          |
	// ----------------------------------------------------------------------
	
	/*
	Method: process
	Runs "process" of all actions
	
	Returns: nil
	*/
	
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		private _state = CALLM(_thisObject, "processSubactions", []);
		SETV(_thisObject, "state", _state);
		_state
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    P R O C E S S   S U B G O A L S                 |
	// ----------------------------------------------------------------------
	
	METHOD("processSubactions") {
		params [["_thisObject", "", [""]]];
		private _subactions = GETV(_thisObject, "subactions");
		
		private _subactionsStates = _subactions apply {
			pr _state = GETV(_x, "state");
			if (_state == ACTION_STATE_ACTIVE || _state == ACTION_STATE_INACTIVE) then {
				CALLM(_x, "process", [])
			} else {
				_state
			};
		};
		
		// Are all subactions completed?
		private _countCompleted = {_x == ACTION_STATE_COMPLETED} count _subactionsStates;
		if (_countCompleted == count _subactions) exitWith { ACTION_STATE_COMPLETED };
		
		// Has any subaction failed?
		private _countFailed = {_x == ACTION_STATE_FAILED} count _subactionsStates;
		if (_countFailed > 0) exitWith { ACTION_STATE_FAILED };
		
		// Are there any active actions?
		private _countActive = {_x == ACTION_STATE_ACTIVE} count _subactionsStates;
		if (_countActive > 0) exitWith { ACTION_STATE_ACTIVE };
		
		// Otherwise return inactive state
		ACTION_STATE_INACTIVE
	} ENDMETHOD;
	
	/*
	Method: terminate
	Calls "terminate" on all actions
	
	Returns: nil
	*/
	METHOD("terminate") {
		params ["_thisObject"];
		
		pr _subactions = T_GETV("subactions");
		{
			CALLM0(_x, "terminate");
		} forEach _subactions;
		
	} ENDMETHOD;



ENDCLASS;