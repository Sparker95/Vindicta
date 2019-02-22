#include "common.hpp"
/*
Goal for a garrison to relax
*/

#define pr private

CLASS("GoalGarrisonRelax", "Goal")

	STATIC_VARIABLE("effects"); // Array of world properties
	
	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	
	/*
	
	STATIC_METHOD("calculateRelevance") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]]];
			GOAL_RELEVANCE_GARRISON_RELAX // Always some small non-zero relevance for the relax goal
	} ENDMETHOD;
	*/

ENDCLASS;