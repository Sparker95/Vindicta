#include "common.hpp"

/*
Author: Marvis 09.05.2019
*/

#define pr private

CLASS("GoalUnitArrest", "Goal")

	STATIC_METHOD("createPredefinedAction") {
	params [ ["_thisClass", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]]];
		
			pr _target = CALLSM2("Action", "getParameterValue", _parameters, "target");
			systemChat format ["GoalUnitArrest target: %1", _target];

			pr _args = [_AI, _target];
			pr _action = NEW("ActionUnitArrest", _args);
			_action

	} ENDMETHOD;

ENDCLASS;