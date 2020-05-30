#include "common.hpp"
FIX_LINE_NUMBERS()
/*
Author: Sparker
Unit will dismount his vehicle if he's in one, walk to a vehicle and repair it.

parameters: "vehicle" - <Unit> of the vehicle that needs repairs
*/

#define pr private

#define OOP_CLASS_NAME GoalUnitRepairVehicle
CLASS("GoalUnitRepairVehicle", "Goal")

	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_REPAIR, [objNull]] ],	// Required parameters
			[]	// Optional parameters
		]
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		// Vehicle usage is forbidden
		CALLM1(_ai, "setAllowVehicleWSP", false);
	ENDMETHOD;

ENDCLASS;