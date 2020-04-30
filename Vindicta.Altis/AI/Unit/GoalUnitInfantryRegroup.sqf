#include "common.hpp"

/*
Author: Sparker
Unit will dismount his vehicle and start following his leader
*/

#define pr private

#define OOP_CLASS_NAME GoalUnitInfantryRegroup
CLASS("GoalUnitInfantryRegroup", "Goal")

	/* virtual */ STATIC_METHOD(createPredefinedAction)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		pr _hO = GETV(_AI, "hO");

		// Check if the unit has been assigned to any vehicle
		pr _vehicle = CALLM0(_AI, "getAssignedVehicle");

		if (_vehicle != NULL_OBJECT || !(vehicle _hO isEqualTo _hO)) then {
			pr _actionSerial = NEW("ActionCompositeSerial", [_AI]);
			pr _actionDismount = NEW("ActionUnitDismountCurrentVehicle", [_AI ARG _parameters]);
			CALLM1(_actionSerial, "addSubactionToBack", _actionDismount);
			pr _actionRegroup = NEW("ActionUnitInfantryRegroup", [_AI ARG _parameters]);
			CALLM1(_actionSerial, "addSubactionToBack", _actionRegroup);
			_actionSerial
		} else {
			pr _action = NEW("ActionUnitInfantryRegroup", [_AI ARG _parameters]);
			_action
		};

	ENDMETHOD;

ENDCLASS;