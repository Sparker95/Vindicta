#include "common.hpp"

/*
Author: Sparker
Unit will dismount his vehicle and start following his leader
*/

#define pr private

CLASS("GoalUnitInfantryRegroup", "Goal")

	// ----------------------------------------------------------------------
	// |            C R E A T E   P R E D E F I N E D   A C T I O N
	// ----------------------------------------------------------------------
	// By default it gets predefined action from database if it is defined and creates it, passing a goal parameter to action parameter, if it exists
	// This method must be redefined for goals that have predefined actions that require parameters not from goal parameters

	/* virtual */ STATIC_METHOD("createPredefinedAction") {
		params [ ["_thisClass", "", [""]], ["_AI", "", [""]], ["_parameters", [], [[]]]];

		pr _hO = GETV(_AI, "hO");

		// Check if the unit has been assigned to any vehicle
		pr _vehicle = CALLM0(_AI, "getAssignedVehicle");

		if (_vehicle != "" || (!(vehicle _hO isEqualTo _hO))) then {
			pr _actionSerial = NEW("ActionCompositeSerial", [_AI]);
			pr _actionDismount = NEW("ActionUnitDismountCurrentVehicle", [_AI]);
			pr _actionRegroup = NEW("ActionUnitInfantryRegroup", [_AI]);
			CALLM1(_actionSerial, "addSubactionToBack", _actionDismount);
			CALLM1(_actionSerial, "addSubactionToBack", _actionRegroup);
			_actionSerial
		} else {
			pr _action = NEW("ActionUnitInfantryRegroup", [_AI]);
			_action
		};

	} ENDMETHOD;

ENDCLASS;