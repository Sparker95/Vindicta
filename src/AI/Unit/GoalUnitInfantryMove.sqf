#include "common.hpp"

/*
Author: Sparker
*/

#define pr private

#define OOP_CLASS_NAME GoalUnitInfantryMove
CLASS("GoalUnitInfantryMove", "GoalUnit")

	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_MOVE_TARGET, [[], objNull, NULL_OBJECT]] ],	// Required parameters
			[ [TAG_MOVE_RADIUS, [0]], [TAG_BUILDING_POS_ID, [0]] ]	// Optional parameters
		]
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		CALLM1(_ai, "setAllowVehicleWSP", false);

		// Set destination
		pr _moveTarget = GET_PARAMETER_VALUE(_goalParameters, TAG_MOVE_TARGET);
		pr _radius = GET_PARAMETER_VALUE_DEFAULT(_goalParameters, TAG_MOVE_RADIUS, -1);
		pr _bposid = GET_PARAMETER_VALUE_DEFAULT(_goalParameters, TAG_BUILDING_POS_ID, -1);

		
		if (_radius == -1) then {
			CALLM1(_ai, "setMoveTargetRadius", 10); // Action can override it anyway
		} else {
			CALLM1(_ai, "setMoveTargetRadius", _radius);
		};

		// Set destination
		if (_bposid != -1) then {
			CALLM2(_ai, "setMoveTargetBuilding", _moveTarget, _bposid);
		} else {
			CALLM1(_ai, "setMoveTarget", _moveTarget);
		};

		// Update world state properties
		T_CALLM0("updatePositionWSP");
	ENDMETHOD;

	// Must return a bool, true or false, if unit can talk while doing this goal
	// Default is false;
	STATIC_METHOD(canTalk)
		true;
	ENDMETHOD;

ENDCLASS;