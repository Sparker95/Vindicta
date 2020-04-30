#include "common.hpp"

/*
Class: Goal.GoalUnitShootLegTarget
Makes a single unit to move to a specified building position.

Parameters:
TAG_TARGET - object handle of the target to shoot
*/
#define pr private

#define OOP_CLASS_NAME GoalUnitShootLegTarget
CLASS("GoalUnitShootLegTarget", "Goal")

	STATIC_METHOD(createPredefinedAction)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		pr _args = [_AI, _parameters];
		pr _action = NEW("ActionUnitShootLegTarget", _args);
		_action

	ENDMETHOD;

ENDCLASS;
