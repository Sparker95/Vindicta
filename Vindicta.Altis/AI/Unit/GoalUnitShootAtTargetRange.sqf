#include "common.hpp"

#define pr private

#define OOP_CLASS_NAME GoalUnitShootAtTargetRange
CLASS("GoalUnitShootAtTargetRange", "Goal")

	STATIC_METHOD(getPossibleParameters)
		[
			[ [TAG_TARGET_SHOOT_RANGE, [objNull]] ],	// Required parameters
			[]	// Optional parameters
		]
	ENDMETHOD;

	STATIC_METHOD(onGoalChosen)
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters")];

		// Vehicle usage is forbidden
		CALLM1(_ai, "setAllowVehicleWSP", false);

		pr _target = GET_PARAMETER_VALUE(_goalParameters, TAG_TARGET_SHOOT_RANGE);
		pr _positions = CALLSM1("ActionUnitShootAtTargetRange", "getShootingPos", _target);

		// Positions are not provided, planning is impossible
		if (count _positions == 0) exitWith {};

		_positions params ["_shootingPos", "_safePos"];
		_goalParameters pushBack [TAG_POS, _shootingPos];

		// Set move target and evaluate if we are close to it already
		CALLM1(_ai, "setMoveTarget", _shootingPos);
		CALLM1(_ai, "setMoveTargetRadius", 2);
		CALLM0(_ai, "updatePositionWSP");

	ENDMETHOD;

ENDCLASS;