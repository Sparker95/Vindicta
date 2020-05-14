#include "common.hpp"

/*
Author: Sparker
*/

#define pr private

#define OOP_CLASS_NAME GoalUnitInfantryMoveBuilding
CLASS("GoalUnitInfantryMoveBuilding", "Goal")

	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_BUILDING, [objNull] ], [TAG_BUILDING_POS_ID, [0]] ],	// Required parameters
			[ [TAG_MOVE_RADIUS, [0]], [TAG_DURATION_SECONDS, [0]], [TAG_TELEPORT, [false]] ]	// Optional parameters
		]
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		CALLM1(_ai, "setAllowVehicleWSP", false);

		// Set destination
		pr _moveTarget = GET_PARAMETER_VALUE(_goalParameters, TAG_TARGET_BUILDING);
		pr _bposid = GET_PARAMETER_VALUE(_goalParameters, TAG_BUILDING_POS_ID);
		pr _radius = GET_PARAMETER_VALUE_DEFAULT(_goalParameters, TAG_RADIUS, -1);
		CALLM2(_ai, "setMoveTargetBuilding", _bposid, _bposid);
		if (_radius == -1) then {
			CALLM1(_ai, "setMoveRadius", 2); // Action can override it anyway
		} else {
			CALLM1(_ai, "setMoveRadius", _radius);
		};
		
	ENDMETHOD;

ENDCLASS;