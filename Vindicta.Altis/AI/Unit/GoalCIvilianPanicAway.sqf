#include "common.hpp"

#define pr private

/*
Unit will try to run to a spot far away from here
*/

#define OOP_CLASS_NAME GoalCivilianPanicAway
CLASS("GoalCivilianPanicAway", "Goal")

	/* override */ STATIC_METHOD(createPredefinedAction)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		// Select a random waypoint, create action to move there
		pr _hO = CALLM0(GETV(_AI, "agent"), "getObjectHandle");
		pr _cp = GETV(_AI, "civPresence");
		pr _pos = CALLM1(_cp, "getFarthestSafeSpot", getPos _hO);
		pr _args = [_AI, [[TAG_POS, _pos]]];
		pr _actionFlee = NEW("ActionUnitFlee", _args);

		_actionFlee
	ENDMETHOD;

	STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];

		// If in danger and someone is close
		if (GETV(_AI, "danger")) then {

			pr _hO = CALLM0(GETV(_AI, "agent"), "getObjectHandle");
			pr _nearMen = (_hO nearobjects ["CAManBase", 6]) - [_hO];

			if (count _nearMen > 0) then {
				GET_STATIC_VAR(_thisClass, "relevance");
			} else {
				0
			};
		} else {
			0
		};
	ENDMETHOD;

ENDCLASS;