#include "common.hpp"
/*
Goal for a garrison to go destroy some enemies
*/

#define pr private

CLASS("GoalGarrisonAttackAssignedTargets", "Goal")

	STATIC_METHOD("calculateRelevance") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]]];
		
		// Return active relevance when we see assigned targets
		if (GETV(_AI, "awareOfAssignedTarget")) then {
			pr _intrinsicRelevance = GET_STATIC_VAR(_thisClass, "relevance");
			 // Return relevance
			_intrinsicRelevance
		} else {
			0
		};
	} ENDMETHOD;

	STATIC_METHOD("getEffects") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]]];

		pr _pos = GETV(_AI, "assignedTargetsPos");
		
		pr _ws = [WSP_GAR_COUNT] call ws_new;
		[_ws, WSP_GAR_CLEARING_AREA, _pos] call ws_setPropertyValue;

		_ws		
	} ENDMETHOD;

ENDCLASS;