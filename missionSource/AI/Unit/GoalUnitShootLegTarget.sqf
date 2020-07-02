#include "common.hpp"

/*
Class: Goal.GoalUnitShootLegTarget

*/
#define pr private

#define OOP_CLASS_NAME GoalUnitShootLegTarget
CLASS("GoalUnitShootLegTarget", "GoalUnit")

	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_SHOOT_LEG, [objNull]] ],	// Required parameters
			[]	// Optional parameters
		]
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		// Vehicle usage is forbidden
		CALLM1(_ai, "setAllowVehicleWSP", false);

	ENDMETHOD;

ENDCLASS;
