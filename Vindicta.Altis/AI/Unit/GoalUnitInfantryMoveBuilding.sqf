#include "common.hpp"

/*
Author: Sparker

Parameters:
"building" - object handle of the building
"posID" - ID of the building position used with buildingPos command
*/

#define pr private

#define OOP_CLASS_NAME GoalUnitInfantryMoveBuilding
CLASS("GoalUnitInfantryMoveBuilding", "Goal")

	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_OBJECT, [objNull] ], [TAG_BUILDING_POS_ID, [0]] ],	// Required parameters
			[ [TAG_MOVE_RADIUS, [0]], [TAG_DURATION_SECONDS, [0]], [TAG_TELEPORT, [false]] ]	// Optional parameters
		]
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		CALLM1(_ai, "setAllowVehicleWSP", false);
	ENDMETHOD;

ENDCLASS;