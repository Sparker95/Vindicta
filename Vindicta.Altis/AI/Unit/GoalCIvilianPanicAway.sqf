#include "common.hpp"

#define pr private

/*
Unit will try to run to a spot far away from here
*/

#define OOP_CLASS_NAME GoalCivilianPanicAway
CLASS("GoalCivilianPanicAway", "GoalUnit")

	STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];

		// If in danger and someone is close
		if (GETV(_AI, "danger")) then {

			pr _hO = CALLM0(GETV(_AI, "agent"), "getObjectHandle");
			pr _nearMen = (_hO nearobjects ["CAManBase", 6]) - [_hO];

			if (count _nearMen > 0) then {
				GETSV(_thisClass, "relevance");
			} else {
				0
			};
		} else {
			0
		};
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		// Vehicle usage is forbidden
		CALLM1(_ai, "setAllowVehicleWSP", false);

		pr _hO = CALLM0(GETV(_AI, "agent"), "getObjectHandle");
		pr _cp = GETV(_AI, "civPresence");
		pr _pos = CALLM1(_cp, "getFarthestSafeSpot", getPos _hO);
		
		_goalParameters pushBack [TAG_POS, _pos];

	ENDMETHOD;

ENDCLASS;