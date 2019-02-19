/*
Goal for a garrison to relax
*/

#include "..\..\OOP_Light\OOP_Light.h"
#include "..\WorldState\WorldState.hpp"
#include "garrisonWorldStateProperties.hpp"
#include "..\goalRelevance.hpp"

#define pr private

CLASS("GoalGarrisonRebalanceVehicleGroups", "Goal")

	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	// Inherited classes must implement this
	// By default returns instrinsic goal relevance
	
	/* virtual */ STATIC_METHOD("calculateRelevance") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]]];
		
		pr _ws = GETV(_AI, "worldState");
		
		if ([_ws, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_DRIVERS, false] call ws_propertyExistsAndEquals || 
			[_ws, WSP_GAR_ALL_VEHICLE_GROUPS_HAVE_TURRET_OPERATORS, false] call ws_propertyExistsAndEquals) then {
			GET_STATIC_VAR(_thisClass, "relevance");
		} else {
			0
		};
	} ENDMETHOD;

ENDCLASS;