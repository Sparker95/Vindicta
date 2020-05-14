#include "common.hpp"

#define OOP_CLASS_NAME GoalUnitAmbientAnim
CLASS("GoalUnitAmbientAnim", "Goal")

	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_AMBIENT_ANIM, [objNull]] ],	// Required parameters
			[]	// Optional parameters
		]
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		// Vehicle usage is forbidden
		CALLM1(_ai, "setAllowVehicleWSP", false);
	ENDMETHOD;

ENDCLASS;