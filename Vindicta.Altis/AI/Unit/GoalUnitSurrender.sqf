#include "common.hpp"

/*
Class: Goal.GoalUnitSurrender
*/

#define OOP_CLASS_NAME GoalUnitSurrender
CLASS("GoalUnitSurrender", "Goal")

	// ----------------------------------------------------------------------
	// |            C R E A T E   P R E D E F I N E D   A C T I O N
	// ----------------------------------------------------------------------
	// By default it gets predefined action from database if it is defined and creates it, passing a goal parameter to action parameter, if it exists
	// This method must be redefined for goals that have predefined actions that require parameters not from goal parameters
	
	STATIC_METHOD(createPredefinedAction)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		
		private _objectHandle = GETV(_AI, "hO");

		if (vehicle _objectHandle != _objectHandle) then {
			private _actionSerial = NEW("ActionCompositeSerial", [_AI]);

			private _actionDismount = NEW("ActionUnitDismountCurrentVehicle", [_AI]);
			CALLM1(_actionSerial, "addSubactionToFront", _actionDismount);

			private _actionSurrender = NEW("ActionUnitSurrender", [_AI]);
			CALLM1(_actionSerial, "addSubactionToBack", _actionSurrender);

			_actionSerial
		} else {
			private _action = NEW("ActionUnitSurrender", [_AI]);
			_action
		}
	ENDMETHOD;

ENDCLASS;
