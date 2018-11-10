/*
*/

#include "..\..\OOP_Light\OOP_Light.h"
#include "..\WorldState\WorldState.hpp"

CLASS("Goal", "MessageReceiver")

	STATIC_VARIABLE("desiredWorldState"); // Array of world properties
	
	
	// We don't need NEW and DELETE because goals don't need to be instantiated
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]]];
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		
	} ENDMETHOD;
	
	
	
	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	// Inherited classes must implement this
	
	/* virtual */ STATIC_METHOD("calculateRelevance") {
		params [["_thisObject", "", [""]], ["_AI", "", [""]]];
		0 // Return desireability
	} ENDMETHOD;

ENDCLASS;

SET_STATIC_VAR("Goal", "desiredWorldState", []);