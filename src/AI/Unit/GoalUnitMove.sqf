#include "common.hpp"

#define pr private

#define OOP_CLASS_NAME GoalUnitMove
CLASS("GoalUnitMove", "GoalUnit")

	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_POS, [[]] ] ],	// Required parameters
			[ [TAG_MOVE_RADIUS, [0]], [TAG_ROUTE, [[]]] ]	// Optional parameters
		]
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];
		CALLM1(_ai, "setAllowVehicleWSP", true);

		// Set destination
		pr _moveTarget = GET_PARAMETER_VALUE(_goalParameters, TAG_POS);
		pr _radius = GET_PARAMETER_VALUE_DEFAULT(_goalParameters, TAG_MOVE_RADIUS, -1);
		pr _bposid = GET_PARAMETER_VALUE_DEFAULT(_goalParameters, TAG_BUILDING_POS_ID, -1);

		
		if (_radius == -1) then {
			CALLM1(_ai, "setMoveTargetRadius", 2); // Action can override it anyway
		} else {
			CALLM1(_ai, "setMoveTargetRadius", _radius);
		};

		// Set destination
		CALLM1(_ai, "setMoveTarget", _moveTarget);

		// Update world state properties
		T_CALLM0("updatePositionWSP");
	ENDMETHOD;

	// Must return a bool, true or false, if unit can talk while doing this goal
	// Default is false;
	STATIC_METHOD(canTalk)
		true;
	ENDMETHOD;

ENDCLASS;