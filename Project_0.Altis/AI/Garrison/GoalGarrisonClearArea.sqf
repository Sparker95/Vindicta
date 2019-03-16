#include "common.hpp"
/*
Goal for a garrison to go destroy some enemies
*/

#define pr private

CLASS("GoalGarrisonClearArea", "Goal")

	/*
	// Legacy sh1t, delete it some day
	// Now it migrated to GoalGarrisonAttackAssignedTargets goal
	STATIC_METHOD("calculateRelevance") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]]];
		
		pr _ws = GETV(_AI, "worldState");
		pr _inCombat = ([_ws, WSP_GAR_AWARE_OF_ENEMY, true] call ws_getPropertyValue);
		pr _awareOfAssignedTarget = GETV(_AI, "awareOfAssignedTarget");
		pr _gar = GETV(_AI, "agent");
		pr _distanceToAssignedTarget = GETV(_AI, "assignedTargetsPos") distance2D CALLM0(_gar, "getPos");
		
		// Return active relevance when we see assigned targets or when we are not in combat
		if (GETV(_AI, "awareOfAssignedTarget") || !_inCombat) then {
			pr _intrinsicRelevance = GET_STATIC_VAR(_thisClass, "relevance");
			 // Return relevance
			_intrinsicRelevance
		} else {
			0
		};
	} ENDMETHOD;
	*/

ENDCLASS;