/*
*/

#include "..\..\OOP_Light\OOP_Light.h"
#include "..\WorldState\WorldState.hpp"

CLASS("Goal", "MessageReceiver")

	STATIC_VARIABLE("worldState"); // Array of world properties
	
	// ----------------------------------------------------------------------
	// |                              N E W                                 |
	// ----------------------------------------------------------------------
	
	METHOD("new") {
		params [["_thisObject", "", [""]] ];
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                            D E L E T E                             |
	// ----------------------------------------------------------------------
	
	METHOD("delete") {
		params [["_thisObject", "", [""]]];
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   D E S I R E A B I L I T Y           |
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _agent
	// Inherited classes must implement this
	
	/* virtual */ STATIC_METHOD("calculateDesireability") {
		params [["_thisObject", "", [""]], ["_agent", "", [""]]];
		0 // Return desireability
	} ENDMETHOD;

ENDCLASS;

SET_STATIC_VAR("Goal", "worldState", []);