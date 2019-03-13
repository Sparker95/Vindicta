#include "common.hpp"

/*
Class: ActionGroup
Group action.
*/

#define pr private

#define THIS_ACTION_NAME "MyAction"

CLASS("ActionGroup", "Action")

	
	VARIABLE("hG");
	VARIABLE("group");
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]] ];
		
		ASSERT_OBJECT_CLASS(_AI, "AIGroup");
		
		pr _agent = GETV(_AI, "agent");
		T_SETV("group", _agent);
		pr _hG = CALLM0(_agent, "getGroupHandle"); // Group handle
		SETV(_thisObject, "hG", _hG);
	} ENDMETHOD;
	
	/*
	Method: failIfEmpty
	Sets this action to failed state if there are no units
	
	Returns: action state
	*/
	METHOD("failIfEmpty") {
		params ["_thisObject"];
		if (CALLM0(T_GETV("group"), "isEmpty")) then {
			T_SETV("state", ACTION_STATE_FAILED);
			ACTION_STATE_FAILED
		} else {
			T_GETV("state")
		};
	} ENDMETHOD;

	/*
	Method: handleUnitsRemoved
	Handles what happened when units get removed from its group while the group has some action operational.
	By default it does nothing.
	
	How it gets called: called by <AIGroup> directly.
	
	Parameters: _unit
	
	_unit - <Unit>
	
	Returns: nil
	*/
	
	METHOD("handleUnitsRemoved") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]]];
		
	} ENDMETHOD;
	
	/*
	Method: handleUnitsAdded
	Handles what happened when units get added to its group while the group has some action operational.
	By default it does nothing.
	
	How it gets called: called by <AIGroup> directly.
	
	Parameters: _unit
	
	_unit - <Unit>
	
	Returns: nil
	*/
	
	METHOD("handleUnitsAdded") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]]];
		
	} ENDMETHOD;
	
ENDCLASS;