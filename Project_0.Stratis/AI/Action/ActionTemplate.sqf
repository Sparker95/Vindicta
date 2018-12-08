#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\Action\Action.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"
#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"

/*
Template of an Action class
*/

#define pr private

#define THIS_ACTION_NAME "MyAction"

CLASS("MyAction", "Action")

	VARIABLE("AI");
	
	//STATIC_VARIABLE("preconditions"); // World state which must be satisfied for this action to start
	//STATIC_VARIABLE("effects"); // World state after the action ahs been executed
	
	// ------------ N E W ------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]] ];
		SETV(_thisObject, "AI", _AI);
	} ENDMETHOD;
	
	// logic to run when the goal is activated
	METHOD("activate") {
		params [["_to", "", [""]]];		
		
		// Set state
		SETV(_thisObject, "state", ACTION_STATE_ACTIVE);
		
		// Return ACTIVE state
		ACTION_STATE_ACTIVE
		
	} ENDMETHOD;
	
	// logic to run each update-step
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		CALLM(_thisObject, "activateIfInactive", []);
		
		// Return the current state
		ACTION_STATE_ACTIVE
	} ENDMETHOD;
	
	// logic to run when the action is satisfied
	METHOD("terminate") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD;
	
	
	// Calculates cost of this action
	STATIC_METHOD("getCost") {
		params [["_AI", "", [""]], ["_wsStart", [], [[]]], ["_wsEnd", [], [[]]]];
		
		// Return cost
		0
	} ENDMETHOD;

ENDCLASS;

// Set effects and preconditions
/*
pr _wsPre = [WSP_GAR_COUNT] call ws_new;
[_wsPre, WSP_GAR_ALL_CREW_MOUNTED, true] call ws_setPropertyValue;
SET_STATIC_VAR(THIS_ACTION_NAME, "preconditions", _wsPre); // World state

pr _wsEff = [WSP_GAR_COUNT] call ws_new;
[_wsEff, WSP_GAR_ALL_CREW_MOUNTED, true] call ws_setPropertyValue;
SET_STATIC_VAR(THIS_ACTION_NAME, "effects", _wsEff); // World state
*/