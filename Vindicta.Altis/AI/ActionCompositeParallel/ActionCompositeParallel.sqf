#include "..\..\common.h"
#include "..\Action\Action.hpp"

/*
Class: Action.ActionCompositeParallel
NYI

Not really sure if it's needed.

Parallel action evaluates all subactions at once.

It returns:
COMPLETED if all subactions are in COMPLETED state
REPLAN if any subaction requested a replan
FAILED if any subaction has failed
INACTIVE right after this action creation
ACTIVE otherwise

Author: Sparker 05.08.2018
*/

#define pr private

#define OOP_CLASS_NAME ActionCompositeParallel
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
	
	METHOD(process)
		params [P_THISOBJECT];
		private _state = T_CALLM("processSubactions", []);
		T_SETV("state", _state);
		_state
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    P R O C E S S   S U B G O A L S                 |
	// ----------------------------------------------------------------------
	
	METHOD(processSubactions)
		params [P_THISOBJECT];
		private _subactions = T_GETV("subactions");
		
		private _subactionsStates = _subactions apply {
			pr _state = GETV(_x select 0, "state");
			if (_state == ACTION_STATE_ACTIVE || _state == ACTION_STATE_INACTIVE) then {
				CALLM0(_x select 0, "process")
			} else {
				_state
			};
		};
		
		// Are all subactions completed?
		private _countCompleted = {_x == ACTION_STATE_COMPLETED} count _subactionsStates;
		if (_countCompleted == count _subactions) exitWith { ACTION_STATE_COMPLETED };
		
		// Has any action requested a replan?
		private _countReplan = {_x == ACTION_STATE_REPLAN} count _subactionsStates;
		if (_countReplan > 0) exitWith { ACTION_STATE_REPLAN };

		// Has any subaction failed?
		private _countFailed = {_x == ACTION_STATE_FAILED} count _subactionsStates;
		if (_countFailed > 0) exitWith { ACTION_STATE_FAILED };
		
		// Are there any active actions?
		private _countActive = {_x == ACTION_STATE_ACTIVE} count _subactionsStates;
		if (_countActive > 0) exitWith { ACTION_STATE_ACTIVE };
		
		// Otherwise return inactive state
		ACTION_STATE_INACTIVE
	ENDMETHOD;
	
	/*
	Method: terminate
	Calls "terminate" on all actions
	
	Returns: nil
	*/
	METHOD(terminate)
		params [P_THISOBJECT];
		
		pr _subactions = T_GETV("subactions");
		{
			CALLM0(_x select 0, "terminate");
		} forEach _subactions;
		
	ENDMETHOD;

	/*
	Method: handleUnitsAdded
	Calls the same method for all subactions.
	*/
	
	METHOD(handleUnitsAdded)
		params [P_THISOBJECT, P_ARRAY("_units")];
		private _subactions = T_GETV("subactions");
		{
			CALLM1(_x select 0, "handleUnitsAdded", _units);
		} forEach _subactions;
	ENDMETHOD;
	
	/*
	Method: handleUnitsRemoved
	Calls the same method for all subactions.
	*/
	
	METHOD(handleUnitsRemoved)
		params [P_THISOBJECT, P_ARRAY("_units")];
		private _subactions = T_GETV("subactions");
		{
			CALLM1(_x select 0, "handleUnitsRemoved", _units);
		} forEach _subactions;
	ENDMETHOD;

	/*
	Method: handleGroupsAdded
	Calls the same method of all subaction.
	
	Parameters: _groups
	
	_groups - Array of <Group>
	
	Returns: nil
	*/
	METHOD(handleGroupsAdded)
		params [P_THISOBJECT, P_ARRAY("_groups")];
		
		pr _subactions = T_GETV("subactions");
		{
			CALLM1(_x select 0, "handleGroupsAdded", _groups);
		} forEach _subactions;
		
		nil
	ENDMETHOD;


	/*
	Method: handleGroupsRemoved
	Calls the same method of all subaction.
	
	Parameters: _groups
	
	_groups - Array of <Group>
	
	Returns: nil
	*/
	METHOD(handleGroupsRemoved)
		params [P_THISOBJECT, P_ARRAY("_groups")];
		
		pr _subactions = T_GETV("subactions");
		{
			CALLM1(_x select 0, "handleGroupsRemoved", _groups);
		} forEach _subactions;
		
		nil
	ENDMETHOD;

ENDCLASS;