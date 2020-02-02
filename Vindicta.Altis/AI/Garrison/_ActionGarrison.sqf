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