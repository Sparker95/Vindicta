/*
Goal for a garrison to move somewhere
*/

#include "..\..\OOP_Light\OOP_Light.h"
#include "..\WorldState\WorldState.hpp"
#include "garrisonWorldStateProperties.hpp"
#include "..\goalRelevance.hpp"

#define pr private

CLASS("GoalGarrisonMove", "Goal")

	STATIC_VARIABLE("effects"); // Array of world properties
	
	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	// Inherited classes must implement this
	
	STATIC_METHOD("calculateRelevance") {
		params [["_AI", "", [""]]];
		
		// Return relevance
		GOAL_RELEVANCE_GARRISON_MOVE

	} ENDMETHOD;

ENDCLASS;

pr _ws = [WSP_GAR_COUNT] call ws_new;
[_ws, WSP_GAR_ALL_VEHICLES_REPAIRED, true] call ws_setPropertyValue;
[_ws, WSP_GAR_ALL_VEHICLES_CAN_MOVE, true] call ws_setPropertyValue;

SET_STATIC_VAR("Goal", "effects", _ws);