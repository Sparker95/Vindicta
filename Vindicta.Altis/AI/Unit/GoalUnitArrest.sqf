#include "common.hpp"

/*
Author: Marvis 09.05.2019
*/

#define pr private

#define OOP_CLASS_NAME GoalUnitArrest
CLASS("GoalUnitArrest", "Goal")

	STATIC_METHOD(createPredefinedAction)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		pr _action = NEW("ActionUnitArrest", [_AI ARG _parameters]);
	
		_action

	ENDMETHOD;

ENDCLASS;