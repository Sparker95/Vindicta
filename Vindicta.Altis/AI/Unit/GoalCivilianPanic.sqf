#include "common.hpp"

#define pr private

#define OOP_CLASS_NAME GoalCivilianPanic
CLASS("GoalCivilianPanic", "Goal")

	/* override */ STATIC_METHOD(createPredefinedAction)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		// Select a random waypoint, create action to move there
		pr _hO = CALLM0(GETV(_AI, "agent"), "getObjectHandle");
		pr _cp = GETV(_AI, "civPresence");
		pr _pos = CALLM1(_cp, "getNearestSafeSpot", getPos _hO);
		pr _args = [_AI, [[TAG_POS, _pos]]];
		pr _actionFlee = NEW("ActionUnitFlee", _args);

		_actionFlee
	ENDMETHOD;

	STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];

		// Return active relevance when we see assigned targets
		if (GETV(_AI, "danger")) then {
			GET_STATIC_VAR(_thisClass, "relevance");
		} else {
			0
		};
	ENDMETHOD;

ENDCLASS;