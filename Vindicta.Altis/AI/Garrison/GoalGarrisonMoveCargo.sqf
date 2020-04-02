#include "common.hpp"
/*
Goal for a garrison to move somewhere
*/

#define pr private

CLASS("GoalGarrisonMoveCargo", "Goal")

	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI
	// Inherited classes must implement this
	
	STATIC_METHOD("calculateRelevance") {
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];
		
		// Return relevance
		GOAL_RELEVANCE_GARRISON_MOVE

	} ENDMETHOD;

ENDCLASS;