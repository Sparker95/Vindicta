#include "common.hpp"

#define OOP_CLASS_NAME GoalGarrisonLand
CLASS("GoalGarrisonLand", "Goal")
	/* override */ STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];
		
		if(!CALLM0(_AI, "isLanded") && {CALLM0(GETV(_AI, "agent"), "getLocation") != NULL_OBJECT}) then {
			GETSV("GoalGarrisonLand", "relevance")
		} else {
			0
		}
	ENDMETHOD;
ENDCLASS;