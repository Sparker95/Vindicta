#include "common.hpp"

/*
Author: Sparker
*/

#define pr private

#define OOP_CLASS_NAME GoalUnitGetInVehicle
CLASS("GoalUnitGetInVehicle", "Goal")

	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_UNIT, [NULL_OBJECT]],  [TAG_VEHICLE_ROLE, [""]] ],	// Required parameters
			[ [TAG_TURRET_PATH, [[]]] ]	// Optional parameters
		]
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		// Vehicle usage is allowed
		CALLM1(_ai, "setAllowVehicleWSP", true);

		// todo implement handling of vehicle world state property
		// todo for this we must move vehicle assignment out of action
		pr _ws = GETV(_ai, "worldState");
		WS_SET(_ws, WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE_ROLE, false);
		WS_SET(_ws, WSP_UNIT_HUMAN_AT_ASSIGNED_VEHICLE, false);
	ENDMETHOD;

ENDCLASS;