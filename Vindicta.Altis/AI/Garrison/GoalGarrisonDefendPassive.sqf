#include "common.hpp"

/*
Goal for a garrison to relax
*/

#define pr private

CLASS("GoalGarrisonDefendPassive", "Goal")

	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	
	STATIC_METHOD("calculateRelevance") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]]];
		
		// Check if the garrison knows about any enemies
		pr _ws = GETV(_AI, "worldState");
		if ([_ws, WSP_GAR_AWARE_OF_ENEMY, true] call ws_propertyExistsAndEquals && CALLM0(_AI, "isSpawned")) then {
			GET_STATIC_VAR(_thisClass, "relevance")
			} else {
			0
		};
	} ENDMETHOD;

ENDCLASS;