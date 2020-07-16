#include "common.hpp"

/*
Author: Marvis 09.05.2019
*/

#define pr private

#define OOP_CLASS_NAME GoalUnitArrest
CLASS("GoalUnitArrest", "GoalUnit")

	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_ARREST, [objNull]] ],	// Required parameters
			[]	// Optional parameters
		]
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		// Vehicle usage is forbidden
		CALLM1(_ai, "setAllowVehicleWSP", false);
		
	ENDMETHOD;

ENDCLASS;