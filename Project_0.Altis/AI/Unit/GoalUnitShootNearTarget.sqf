#include "common.hpp"

/*
Class: Goal.GoalUnitShootNearTarget
Makes a single unit to move to a specified building position.

Parameters:
"target" - object handle of the target to shoot
*/
#define pr private

CLASS("GoalUnitShootNearTarget", "Goal")

	STATIC_METHOD("createPredefinedAction") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]]];

		pr _target = CALLSM2("Action", "getParameterValue", _parameters, "target");
		pr _args = [_AI, _target];
		pr _action = NEW("ActionUnitShootLegTarget", _args);
		_action

	} ENDMETHOD;

ENDCLASS;