/*
Template of a goal class
*/

#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\OOP_Light\OOP_Light.h"
#include "..\..\Message\Message.hpp"
#include "..\..\MessageTypes.hpp"
#include "..\..\GlobalAssert.hpp"
#include "..\Stimulus\Stimulus.hpp"
#include "..\WorldFact\WorldFact.hpp"

#include "..\stimulusTypes.hpp"
#include "..\worldFactTypes.hpp"
#include "..\goalRelevance.hpp"

//Include some forld state properties
#include "garrisonWorldStateProperties.hpp"


#define pr private

CLASS("GoalGarrisonRepairAllVehicles", "Goal")

	STATIC_VARIABLE("desiredWorldState"); // Array of world properties
	
	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	// Inherited classes must implement this
	
	STATIC_METHOD("calculateRelevance") {
		params [["_AI", "", [""]]];
		
	} ENDMETHOD;

ENDCLASS;

pr _ws = [WSP_GAR_COUNT] call ws_new;
[_ws, WSP_GAR_ALL_VEHICLES_REPAIRED, true] call ws_setPropertyValue;
[_ws, WSP_GAR_ALL_VEHICLES_CAN_MOVE, true] call ws_setPropertyValue;


SET_STATIC_VAR("Goal", "desiredWorldState", [WSP_GAR_COUNT]);