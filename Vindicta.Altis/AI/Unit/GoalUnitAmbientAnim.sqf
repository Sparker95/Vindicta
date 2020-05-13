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
		params [P_THISCLASS, P_OOP_OBJECT("_ai"), P_ARRAY("_goalParameters"), P_ARRAY("_ws")];

		pr _targetObj = GET_PARAMETER_VALUE(_goalParameters, TAG_TARGET_AMBIENT_ANIM);

		// We want planner to use a moveToObject and it needs a TAG_TARGET_OBJECT parameter
		_goalParameters pushBack [TAG_TARGET_OBJECT, _targetObj];

		// Vehicle usage is forbidden
		CALLM1(_ai, "setAllowVehicleWSP", false);

		// Set target for move action
		CALLM2(_ai, "setTargetObject", _targetObj);
		CALLM1(_ai, "setTargetRadius", 1.5);
		CALLM0(_ai, "updatePositionWSP");	// Evaluate if we are close enough to it

	ENDMETHOD;

ENDCLASS;