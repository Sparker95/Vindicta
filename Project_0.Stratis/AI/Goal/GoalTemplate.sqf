#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"

#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"
#include "..\goalRelevance.hpp"

/*
Template of a goal class
*/

//Include some forld state properties
#include "garrisonWorldStateProperties.hpp"


#define pr private

CLASS("MyGoal", "Goal")

	STATIC_VARIABLE("effects"); // Array of world properties
	
	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	// Inherited classes must implement this
	
	STATIC_METHOD("calculateRelevance") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]]];
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |            C R E A T E   P R E D E F I N E D   A C T I O N
	// ----------------------------------------------------------------------
	// If this goal has doesn't support planner and supports a predefined plan, this method must
	// create an Action and return it.
	// Otherwise it must return ""
	
	/* virtual */ STATIC_METHOD("createPredefinedAction") {
		params [ ["_thisClass", "", [""]], ["_thisObject", "", [""]], ["_AI", "", [""]]];
		"" // Return nothing by default
	} ENDMETHOD;

ENDCLASS;

pr _ws = [WSP_GAR_COUNT] call ws_new;
[_ws, WSP_GAR_ALL_VEHICLES_REPAIRED, true] call ws_setPropertyValue;
[_ws, WSP_GAR_ALL_VEHICLES_CAN_MOVE, true] call ws_setPropertyValue;


SET_STATIC_VAR("Goal", "effects", _ws);