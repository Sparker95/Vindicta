#include "common.hpp"

#define OOP_CLASS_NAME GoalUnitFollow
CLASS("GoalUnitFollow", "GoalUnit")

	STATIC_METHOD(getPossibleParameters)
		[
			[ ],	// Required parameters
			[ [TAG_TARGET_OBJECT, [objNull]] ]	// Optional parameters
		]
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		// Vehicle usage is allowed
		CALLM1(_ai, "setAllowVehicleWSP", true);
	ENDMETHOD;

ENDCLASS;