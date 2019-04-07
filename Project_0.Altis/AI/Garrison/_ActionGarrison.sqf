#include "common.hpp"

/*
Class: ActionGarrison
Garrison action.
*/

#define pr private

CLASS("ActionGarrison", "Action")

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
		
		nil
	} ENDMETHOD;
	
	
	/*
	Method: handleUnitsRemoved
	Handles what happens when units get removed from their garrison, for instance when they gets destroyed, while this action is running.
	
	Access: internal
	
	Parameters: _units
	
	_units - Array of <Unit> objects
	
	Returns: nil
	*/
	METHOD("handleUnitsRemoved") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]]];
		
		nil
	} ENDMETHOD;
	
	/*
	Method: handleUnitsAdded
	Handles what happens when units get added to a garrison while this action is running.
	
	Access: internal
	
	Parameters: _unit
	
	_units - Array of <Unit> objects
	
	Returns: nil
	*/
	METHOD("handleUnitsAdded") {
		params [["_thisObject", "", [""]], ["_units", [], [[]]]];
		
		nil
	} ENDMETHOD;

	/*
	Method: spawn
	Gets called from Garrison.spawn. It must perform non-standard spawning of garrison while this action is active.
	
	Returns: Bool. Return true if you have handled spawning here. If you return false, Garrison.spawn will perform spawning on its own.
	*/
	METHOD("spawn") {
		params ["_thisObject"];
		false
	} ENDMETHOD;

	/*
	Method: onGarrisonSpawned
	Gets called after the garrison has been spawned.
	
	Returns: Nothing.
	*/
	METHOD("onGarrisonSpawned") {
		params ["_thisObject"];
	} ENDMETHOD;
	
	/*
	Method: onGarrisonDespawned
	Gets called after the garrison has been despawned.
	
	Returns: Nothing.
	*/
	METHOD("onGarrisonDespawned") {
		params ["_thisObject"];
	} ENDMETHOD;

ENDCLASS;