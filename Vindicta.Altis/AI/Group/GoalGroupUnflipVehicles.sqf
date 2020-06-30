#include "common.hpp"

/*
Goal for a group to unflip their vehicles.
*/

#define pr private

#define OOP_CLASS_NAME GoalGroupUnflipVehicles
CLASS("GoalGroupUnflipVehicles", "GoalGroup")


	// ----------------------------------------------------------------------
	// |            C A L C U L A T E   R E L E V A N C E
	// ----------------------------------------------------------------------
	// Calculates desireability to choose this goal for a given _AI

	public STATIC_METHOD(calculateRelevance)
		params [P_THISCLASS, P_OOP_OBJECT("_AI")];
		
		pr _group = GETV(_AI, "agent");
		pr _groupType = CALLM0(_group, "getType");
		pr _hG = CALLM0(_group, "getGroupHandle");
		// Check for property value in the world state
		pr _ws = GETV(_AI, "worldState");
		if (	([_ws, WSP_GROUP_ALL_VEHICLES_UPRIGHT, false] call ws_propertyExistsAndEquals) &&
				((behaviour (leader _hG)) != "COMBAT") &&
				(_groupType == GROUP_TYPE_VEH)) then {
			GETSV(_thisClass, "relevance");
		} else {
			0
		};
	ENDMETHOD;


ENDCLASS;