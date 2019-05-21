#include "common.hpp"
/*
Goal for a garrison to relax
*/

#define pr private

CLASS("GoalGarrisonRelax", "Goal")

	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	
	STATIC_METHOD("calculateRelevance") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]]];
		
		if (time - GETV(_AI, "lastBusyTime") > AI_GARRISON_IDLE_TIME_THRESHOLD) then { // Have we been idling for too long?
			GETSV("GoalGarrisonRelax", "relevance")
		} else {
			0
		};
	} ENDMETHOD;

ENDCLASS;