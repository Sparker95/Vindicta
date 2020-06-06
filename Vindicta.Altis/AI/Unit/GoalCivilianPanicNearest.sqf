#include "common.hpp"

#define pr private

/*
Unit will try to hide in some nearby spot
*/

#define OOP_CLASS_NAME GoalCivilianPanicNearest
CLASS("GoalCivilianPanicNearest", "Goal")

	STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];

		// Panic if in danger
		if (GETV(_AI, "danger")) then {
			GETSV(_thisClass, "relevance");
		} else {
			0
		};
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		// Vehicle usage is forbidden
		CALLM1(_ai, "setAllowVehicleWSP", false);

		// Select a random waypoint, create action to move there
		pr _hO = CALLM0(GETV(_AI, "agent"), "getObjectHandle");
		pr _cp = GETV(_AI, "civPresence");
		pr _pos = CALLM1(_cp, "getNearestSafeSpot", getPos _hO);
		
		_goalParameters pushBack [TAG_POS, _pos];

	ENDMETHOD;

ENDCLASS;