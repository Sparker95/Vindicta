#include "common.hpp"

/*
Author: Sparker
*/

#define pr private

#define OOP_CLASS_NAME GoalUnitInfantryMove
CLASS("GoalUnitInfantryMove", "Goal")

	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_POS, [[]]] ],	// Required parameters
			[ [TAG_MOVE_RADIUS, [0]] ]	// Optional parameters
		]
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		CALLM1(_ai, "setAllowVehicleWSP", false);

		// Set destination
		pr _moveTarget = GET_PARAMETER_VALUE(_goalParameters, TAG_POS);
		pr _radius = GET_PARAMETER_VALUE_DEFAULT(_goalParameters, TAG_RADIUS, -1);
		CALLM1(_ai, "setMoveTarget", _moveTarget);
		if (_radius == -1) then {
			CALLM1(_ai, "setMoveRadius", 2); // Action can override it anyway
		} else {
			CALLM1(_ai, "setMoveRadius", _radius);
		};
	ENDMETHOD;

ENDCLASS;