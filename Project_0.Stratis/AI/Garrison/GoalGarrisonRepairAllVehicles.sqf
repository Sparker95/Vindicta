/*
Goal for a garrison to repair all its vehicles
*/

#include "..\..\OOP_Light\OOP_Light.h"
#include "..\WorldState\WorldState.hpp"
#include "garrisonWorldStateProperties.hpp"
#include "..\goalRelevance.hpp"

#define pr private

CLASS("GoalGarrisonRepairAllVehicles", "Goal")

	STATIC_VARIABLE("effects"); // Array of world properties
	
	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	// Inherited classes must implement this
	
	STATIC_METHOD("calculateRelevance") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]]];
		
		// Check world state properties
		// Return high desireability if we need repairs and an engineer is available
		pr _ws = GETV(_AI, "worldState");
		if ( ([_ws, WSP_GAR_ALL_VEHICLES_CAN_MOVE, false] call ws_propertyExistsAndEquals) ||
			( ([_ws, WSP_GAR_ALL_VEHICLES_REPAIRED, false] call ws_propertyExistsAndEquals ) && ([_ws, WSP_GAR_ENGINEER_AVAILABLE, true] call ws_propertyExistsAndEquals)
			 ) ) then {
			
			// Return relevance
			GETSV("GoalGarrisonRepairAllVehicles", "relevance")
		} else {
			0
		};
	} ENDMETHOD;

ENDCLASS;