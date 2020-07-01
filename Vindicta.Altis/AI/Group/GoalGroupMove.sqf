#include "common.hpp"

// Class with predefined actions in initDatabase.sqf
#define OOP_CLASS_NAME GoalGroupMove
CLASS("GoalGroupMove", "GoalGroup")
	public STATIC_METHOD(createPredefinedAction)
		params [P_THISCLASS, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		private _group = GETV(_AI, "agent");
		private _groupType = CALLM0(_group, "getType");

		// Infantry group will "clear area" by running around looking for enemies
		if (_groupType == GROUP_TYPE_INF) then {
			private _args = [_AI, _parameters];
			private _action = NEW("ActionGroupMove", _args);
			_action
		} else {
			private _actionSerial = NEW("ActionCompositeSerial", [_AI]);

			// Create action to get in vehicles
			/*
			private _getInParams = [
				[TAG_ONLY_COMBAT_VEHICLES, false] // All crew should be mounted
			];
			private _actionGetIn = NEW("ActionGroupGetInVehiclesAsCrew", [_AI ARG _getInParams]);
			CALLM1(_actionSerial, "addSubactionToBack", _actionGetIn);
			*/

			// Start clear area from center, so move there first
			private _actionMove = NEW("ActionGroupMove", [_AI ARG _parameters]);
			CALLM1(_actionSerial, "addSubactionToBack", _actionMove);
			_actionSerial
		};
	ENDMETHOD;
ENDCLASS;
