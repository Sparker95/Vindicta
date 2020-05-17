#include "common.hpp"

// Class: AI.Garrison.GoalGarrisonDefendPassive
// Garrison will be in defensive posture.
// Low priority action.
// Only allowed when garrison is vigilant (known targets or high enemy activity).
#define OOP_CLASS_NAME GoalGarrisonDefendPassive
CLASS("GoalGarrisonDefendPassive", "Goal")
	STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];
		
		// Check if the garrison knows about any enemies
		if (CALLM0(_AI, "isSpawned") && { CALLM0(_AI, "isVigilant") }) then {
			GET_STATIC_VAR(_thisClass, "relevance")
		} else {
			0
		};
	ENDMETHOD;
ENDCLASS;