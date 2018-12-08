/*
Goal for a garrison to relax
*/

#include "..\..\OOP_Light\OOP_Light.h"
#include "..\WorldState\WorldState.hpp"
#include "garrisonWorldStateProperties.hpp"
#include "..\goalRelevance.hpp"

#define pr private

CLASS("GoalGarrisonRelax", "Goal")

	STATIC_VARIABLE("effects"); // Array of world properties
	
	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	// Inherited classes must implement this
	
	STATIC_METHOD("calculateRelevance") {
		params [["_AI", "", [""]]];
			GOAL_RELEVANCE_GARRISON_RELAX // Always some small non-zero relevance for the relax goal
	} ENDMETHOD;

ENDCLASS;

pr _ws = [WSP_GAR_COUNT] call ws_new;

SET_STATIC_VAR("Goal", "effects", _ws);