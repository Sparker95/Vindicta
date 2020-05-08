#include "common.hpp"

#define OOP_CLASS_NAME GoalGroupAirLand
CLASS("GoalGroupAirLand", "Goal")
	/* override */ STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];

		private _ws = GETV(_AI, "worldState");
		private _landed = [_ws, WSP_GROUP_ALL_LANDED, true] call ws_propertyExistsAndEquals;

		// By default only land automatically when at a location
		private _garr = CALLM0(GETV(_AI, "agent"), "getGarrison");
		if(CALLM0(_garr, "getLocation") != NULL_OBJECT && !_landed) then {
			GETSV("GoalGroupAirLand", "relevance")
		} else {
			0
		}
	ENDMETHOD;
ENDCLASS;