#include "common.hpp"

/*
Class: ActionCompositeParallelGarrison
Garrison action.
*/

#define pr private

CLASS("ActionCompositeParallelGarrison", "ActionCompositeParallel")

	VARIABLE("gar");
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]] ];
		
		ASSERT_OBJECT_CLASS(_AI, "AIGarrison");
		
		pr _gar = GETV(_AI, "agent");
		SETV(_thisObject, "gar", _gar);
	} ENDMETHOD;



	/*
	Method: handleGroupsAdded
	Override in your action to perform special handling of what happens when groups are added while your action is running.
	By default it doesn't do anything.
	
	Parameters: _groups
	
	_groups - Array of <Group>
	
	Returns: nil
	*/
	METHOD("handleGroupsAdded") {
		params [["_thisObject", "", [""]], ["_groups", [], [[]]]];
		
		pr _subactions = T_GETV("subactions");
		{
			CALLM1(_x, "handleGroupsAdded", _groups);
		} forEach _subactions;
		
		nil
	} ENDMETHOD;


	/*
	Method: handleGroupsRemoved
	Override in your action to perform special handling of what happens when groups are removed while your action is running.
	By default it doesn't do anything.
	
	Parameters: _groups
	
	_groups - Array of <Group>
	
	Returns: nil
	*/
	METHOD("handleGroupsRemoved") {
		params [["_thisObject", "", [""]], ["_groups", [], [[]]]];
		
		pr _subactions = T_GETV("subactions");
		{
			CALLM1(_x, "handleGroupsRemoved", _groups);
		} forEach _subactions;
		
		nil
	} ENDMETHOD;
	
ENDCLASS;