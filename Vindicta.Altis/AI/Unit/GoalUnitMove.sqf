#include "common.hpp"

#define OOP_CLASS_NAME GoalUnitMove
CLASS("GoalUnitMove", "Goal")

	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_POS, [[]] ] ],	// Required parameters
			[ [TAG_MOVE_RADIUS, [0]], [TAG_ROUTE, [[]]] ]	// Optional parameters
		]
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];
		CALLM1(_ai, "setAllowVehicleWSP", true);
	ENDMETHOD;

ENDCLASS;