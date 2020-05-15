#include "common.hpp"

#define OOP_CLASS_NAME GoalGroupAirLand
CLASS("GoalGroupAirLand", "Goal")
	/* override */ STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];

		// By default only land automatically when at a location
		private _group = GETV(_AI, "agent");
		private _garr = CALLM0(_group, "getGarrison");
		if(CALLM0(_garr, "getLocation") != NULL_OBJECT && !CALLM0(_AI, "isLanded")) then {
			GETSV("GoalGroupAirLand", "relevance")
		} else {
			0
		}
	ENDMETHOD;
ENDCLASS;