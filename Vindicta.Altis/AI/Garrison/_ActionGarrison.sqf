#include "common.hpp"

/*
Class: ActionGarrison
Garrison action.
*/

#define pr private

CLASS("ActionGarrison", "Action")

	VARIABLE("gar");
	VARIABLE("reactivateOnSpawn");
	VARIABLE("replanOnCompositionChange");

	METHOD("new") {
		params [P_THISOBJECT, P_OOP_OBJECT("_AI") ];

		ASSERT_OBJECT_CLASS(_AI, "AIGarrison");

		pr _gar = GETV(_AI, "agent");

		T_SETV("gar", _gar);
		T_SETV("reactivateOnSpawn", true);
		T_SETV("replanOnCompositionChange", true);
	} ENDMETHOD;

	/*
	Method: spawn
	Gets called from Garrison.spawn. It must perform non-standard spawning of garrison while this action is active.
	
	Returns: Bool. Return true if you have handled spawning here. If you return false, Garrison.spawn will perform spawning on its own.
	*/
	/* protected virtual */ METHOD("spawn") {
		params [P_THISOBJECT];
		false
	} ENDMETHOD;

	/*
	Method: onGarrisonSpawned
	Gets called after the garrison has been spawned.
	
	Returns: Nothing.
	*/
	/* protected virtual */ METHOD("onGarrisonSpawned") {
		params [P_THISOBJECT];

		// Reactivate by default
		if(T_GETV("reactivateOnSpawn")) then {
			T_SETV("state", ACTION_STATE_INACTIVE);
		};
	} ENDMETHOD;
	
	/*
	Method: onGarrisonDespawned
	Gets called after the garrison has been despawned.
	
	Returns: Nothing.
	*/
	/* protected virtual */ METHOD("onGarrisonDespawned") {
		params [P_THISOBJECT];

		// Reactivate by default
		if(T_GETV("reactivateOnSpawn")) then {
			T_SETV("state", ACTION_STATE_INACTIVE);
		};
	} ENDMETHOD;

	
	// Handle units/groups added/removed
	METHOD("handleGroupsAdded") {
		params [P_THISOBJECT, P_ARRAY("_groups")];

		// Replan by default
		if(T_GETV("replanOnCompositionChange")) then {
			T_SETV("state", ACTION_STATE_REPLAN);
		};
	} ENDMETHOD;

	METHOD("handleGroupsRemoved") {
		params [P_THISOBJECT, P_ARRAY("_groups")];

		// Replan by default
		if(T_GETV("replanOnCompositionChange")) then {
			T_SETV("state", ACTION_STATE_REPLAN);
		};
	} ENDMETHOD;
	
	METHOD("handleUnitsRemoved") {
		params [P_THISOBJECT, P_ARRAY("_units")];

		// Replan by default
		if(T_GETV("replanOnCompositionChange")) then {
			T_SETV("state", ACTION_STATE_REPLAN);
		};
	} ENDMETHOD;
	
	METHOD("handleUnitsAdded") {
		params [P_THISOBJECT, P_ARRAY("_units")];

		// Replan by default
		if(T_GETV("replanOnCompositionChange")) then {
			T_SETV("state", ACTION_STATE_REPLAN);
		};
	} ENDMETHOD;

ENDCLASS;