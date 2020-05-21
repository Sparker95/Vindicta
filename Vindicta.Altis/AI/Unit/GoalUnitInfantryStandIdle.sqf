#include "common.hpp"

/*
Class: Goal.GoalUnitInfantryStandIdle

*/
#define pr private

#define OOP_CLASS_NAME GoalUnitInfantryStandIdle
CLASS("GoalUnitInfantryStandIdle", "Goal")

	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_STAND_IDLE, [objNull, [], NULL_OBJECT]], [TAG_DURATION_SECONDS, [0]] ],	// Required parameters
			[]	// Optional parameters
		]
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		// Vehicle usage is forbidden
		CALLM1(_ai, "setAllowVehicleWSP", false);

	ENDMETHOD;

ENDCLASS;
