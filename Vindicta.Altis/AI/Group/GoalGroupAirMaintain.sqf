#include "common.hpp"

#define OOP_CLASS_NAME GoalGroupAirMaintain
CLASS("GoalGroupAirMaintain", "Goal")
	/* override */ STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];

		// By default only land automatically when at a location
		private _group = GETV(_AI, "agent");
		private _airUnits = CALLM0(_group, "getAirUnits") apply {
			CALLM0(_x, "getObjectHandle")
		};
		if(!CALLM0(_AI, "isLanded") && _airUnits findIf { fuel _x < 0.1 || damage _x > 0.25 } != NOT_FOUND) then {
			GETSV("GoalGroupAirMaintain", "relevance")
		} else {
			0
		}
	ENDMETHOD;
ENDCLASS;